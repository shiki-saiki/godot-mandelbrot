shader_type canvas_item;

uniform int iteration = 40;
uniform vec2 position = vec2(0.0);
uniform float scale = 2.0;

const mat3 XYL_TO_RGB = mat3(
	vec3(2.0*inversesqrt(6.0), -inversesqrt(6.0), -inversesqrt(6.0)),
	vec3(0.0, inversesqrt(2.0), -inversesqrt(2.0)),
	vec3(1.0, 1.0, 1.0)
);

vec2 cmul(vec2 a, vec2 b) {
	return vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x);
}

vec2 cinv(vec2 a) {
	return vec2(a.x, -a.y)/dot(a, a);
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
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 p = (UV - 0.5)*2.0*scale + position;
	vec2 q = p;
	for (int i = 0; i < iteration; ++i) {
		q = cmul(q, q) + p;
		if (10000.0 < length(q)) {
			break;
		}
	}
	
	COLOR = vec4(complex_to_rgb(cinv(q)), 1.0);
}
