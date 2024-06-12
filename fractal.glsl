#[compute]
#version 460

layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

layout(binding = 0, std140) restrict uniform UniformBuffer {
    float time; // 0: 4
    vec2 position; // 8: 8
    float scale; // 16: 4
    int iteration; // 20: 4
	// size = ceil(24/32)*16 = 32
};

layout(rgba8ui, binding = 1) restrict uniform uimage2D img;

/*
layout(binding = 2, std430) restrict buffer InputData {
    int data_i[];
};

layout(binding = 3, std430) restrict writeonly buffer OutputData {
    int data_o[];
};
*/

const mat3 XYL_TO_RGB = mat3(
	vec3(2.0*inversesqrt(6.0), -inversesqrt(6.0), -inversesqrt(6.0)),
	vec3(0.0, inversesqrt(2.0), -inversesqrt(2.0)),
	vec3(1.0, 1.0, 1.0)
);


vec2 cmul(vec2 a, vec2 b) {
	return vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x);
}

vec2 csq(vec2 z) {
	return vec2(z.x*z.x - z.y*z.y, 2.0*z.x*z.y);
}

vec2 cinv(vec2 a) {
	return vec2(a.x, -a.y) / dot(a, a);
}

// 0 <= x
// 0 < a
// 0 <= result <= 1
float lightness1(float x, float a) {
	float xa = pow(x, a);
	return xa / (1.0 + xa);
}

float invsigmoid(float x, float a) {
	float b = abs(x);
	return pow(b/(1.0 - b), 1.0/a);
}

// 0 <= l <= 1 : lightness
// a : apex of bounding cone
// 0 < b <= 1 : max_value / a
// 0 < c : acuteness
float chroma1(float l, float a, float b, float c) {
	float u = invsigmoid(2.0 * l - 1.0, c);
	float v = invsigmoid(b - 1.0, c);
	return a * (1.0 - lightness1(sqrt(u * u + v * v), c));
}

vec3 complex_to_xyl_v1(vec2 c) {
	float mag = length(c);
	float l = lightness1(mag, 0.75);
	float chr = chroma1(l, sqrt(6.0) / 4.0, 0.85, 1.0);
	vec2 xy = c / mag * chr;
	return vec3(xy.x, xy.y, l);
}

vec3 complex_to_rgb(vec2 z) {
	return XYL_TO_RGB * complex_to_xyl_v1(z);
	//return vec3(z, 1.0);
}


void main() {
    uint n_px = gl_WorkGroupSize.x * gl_NumWorkGroups.x;

    float px_size = 2.0 * scale / float(n_px);
    vec2 top_left = position - scale;

	vec2 p = top_left + px_size*(0.5 + vec2(gl_GlobalInvocationID.xy));
	
	vec2 q = p;
	for (int i = 0; i < iteration; ++i) {
		q = csq(q) + p;
		if (10000.0 < length(q)) {
			break;
		}
	}
	
	vec4 color = vec4(complex_to_rgb(vec2(cinv(q))), 1.0);
	//vec4 color = vec4(float(length(p) < 1.0), 0.5, 0.25, 1.0);
	uvec4 color_u8 = uvec4(color * 255.0);
	
    imageStore(img, ivec2(gl_GlobalInvocationID.xy), color_u8);
}
