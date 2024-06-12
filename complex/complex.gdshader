shader_type canvas_item;

const mat3 XYL_TO_RGB = mat3(
	vec3(2.0*inversesqrt(6.0), -inversesqrt(6.0), -inversesqrt(6.0)),
	vec3(0.0, inversesqrt(2.0), -inversesqrt(2.0)),
	vec3(1.0, 1.0, 1.0)
);

// 0 <= x
// 0 <= result <= 1
// 1.0 -> 0.5
float lightness0(float x) {
	return 2.0 / PI * atan(x);
}

// 0 <= x
// 0 < a
// 0 <= result <= 1
float lightness1(float x, float a) {
	float xa = pow(x, a);
	return xa / (1.0 + xa);
}

// 0 <= x
// 0 <= result <= 1
float lightness1_p5(float x) {
	float sqrtx = sqrt(x);
	return sqrtx / 1.0 + sqrtx;
}

// 0 <= x
// 0 <= result <= 1
float lightness1_i1(float x) {
	return x / (1.0 + x);
}

// 0 <= x
// 0 <= result <= 1
float lightness1_i2(float x) {
	float xx = x * x;
	return xx / (1.0 + xx);
}

// a: triangle apex
// b: acuteness
float chroma0(float l, float a, float b) {
	float u = tan(PI / 2.0 * (l * 2.0 - 1.0));
	float v = tan(PI / 2.0 * (b - 1.0));
	return a * (1.0 - 2.0 / PI * atan(sqrt(u * u + v * v)));
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

vec3 complex_to_xyl_v0(vec2 c) {
	float mag = length(c);
	float l = lightness0(mag);
	float chr = chroma0(l, sqrt(6.0) / 4.0, 0.75);
	vec2 xy = c / mag * chr;
	return vec3(xy.x, xy.y, l);
}

vec3 complex_to_xyl_v1(vec2 c) {
	float mag = length(c);
	float l = lightness1(mag, 0.75);
	float chr = chroma1(l, sqrt(6.0) / 4.0, 0.85, 1.0);
	vec2 xy = c / mag * chr;
	return vec3(xy.x, xy.y, l);
}

vec3 complex_to_xyl_v2(vec2 c) {
	float mag = length(c);
	float l = lightness1(mag, 1.0);
	float chr = chroma1(l, sqrt(6.0) / 4.0, 0.85, 1.0);
	vec2 xy = c / mag * chr;
	return vec3(xy.x, xy.y, l);
}

vec2 cmul(vec2 c0, vec2 c1) {
	return vec2(c0.x * c1.x - c0.y * c1.y, c0.x * c1.y + c0.y * c1.x);
}

vec2 cdiv(vec2 c0, vec2 c1) {
	return vec2(c0.x * c1.x + c0.y * c1.y, c0.y * c1.x - c0.x * c1.y) / (c1.x * c1.x + c1.y * c1.y);
}

vec2 cinv(vec2 c) {
	return vec2(c.x, - c.y) / (c.x * c.x + c.y * c.y);
}

vec3 color00(vec2 p) {
	return XYL_TO_RGB * complex_to_xyl_v0(p);
}

vec3 color01(vec2 p) {
	vec2 p_out = cinv(p);
	return XYL_TO_RGB * complex_to_xyl_v0(p_out);
}

vec3 color02(vec2 p) {
	vec2 p2 = cmul(p, p);
	vec2 p3 = cmul(p2, p);
	vec2 p_out = (p3 - vec2(1.0, 0.0))/(p2 + p + vec2(1.0, 0.0));
	return XYL_TO_RGB * complex_to_xyl_v0(p_out);
}

vec3 color10(vec2 p) {
	return XYL_TO_RGB * complex_to_xyl_v1(p);
}

vec3 color11(vec2 p) {
	vec2 p_out = cinv(p);
	return XYL_TO_RGB * complex_to_xyl_v1(p_out);
}

vec3 color12(vec2 p) {
	vec2 p2 = cmul(p, p);
	vec2 p3 = cmul(p2, p);
	vec2 q = p - vec2(2.0, 1.0);
	vec2 q2 = cmul(q, q);
	vec2 r = p2 + vec2(2.0, 2.0);
	vec2 p_out = cdiv(cmul(p2 - vec2(1.0, 0.0), q2), r);
	return XYL_TO_RGB * complex_to_xyl_v1(p_out);
}

vec3 color20(vec2 p) {
	return XYL_TO_RGB * complex_to_xyl_v2(p);
}

vec3 color21(vec2 p) {
	vec2 p_out = cinv(p);
	return XYL_TO_RGB * complex_to_xyl_v2(p_out);
}

vec3 color22(vec2 p) {
	vec2 p_out = cmul(cmul(p, p), p) - vec2(1.0, 0.0);
	return XYL_TO_RGB * complex_to_xyl_v2(p_out);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float scale = 4.0;
	float n_row = 3.0;
	float n_col = 3.0;
	vec2 region;
	vec2 pos = modf(UV * vec2(n_col, n_row), region);

	pos = (pos - 0.5) * 2.0 * scale;
	switch (int(region.x)) {
		case 0:
			switch (int(region.y)) {
				case 0:
					COLOR.rgb = color00(pos);
					break;
				case 1:
					COLOR.rgb = color01(pos);
					break;
				case 2:
					COLOR.rgb = color02(pos);
					break;
			}
			break;
		case 1:
			switch (int(region.y)) {
				case 0:
					COLOR.rgb = color10(pos);
					break;
				case 1:
					COLOR.rgb = color11(pos);
					break;
				case 2:
					COLOR.rgb = color12(pos);
					break;
			}
			break;
		case 2:
			switch (int(region.y)) {
				case 0:
					COLOR.rgb = color20(pos);
					break;
				case 1:
					COLOR.rgb = color21(pos);
					break;
				case 2:
					COLOR.rgb = color22(pos);
					break;
			}
			break;
	}
}
