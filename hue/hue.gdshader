shader_type canvas_item;

vec2 cmul(vec2 c0, vec2 c1) {
	return vec2(c0.x * c1.x - c0.y * c1.y, c0.x * c1.y + c0.y * c1.x);
}

vec2 cdiv(vec2 c0, vec2 c1) {
	return vec2(c0.x * c1.x + c0.y * c1.y, c0.y * c1.x - c0.x * c1.y) / (c1.x * c1.x + c1.y * c1.y);
}

vec2 cinv(vec2 c) {
	return vec2(c.x, - c.y) / (c.x * c.x + c.y * c.y);
}

// 0 <= hue <= 1
vec3 hue_to_rgb_v0(float hue) {
	vec3 offset = vec3(2.0, 0.0, 4.0);
	vec3 v = mod(6.0 * hue + offset, 6.0);
	return clamp(min(v, 4.0 - v), 0.0, 1.0);
}

// 0 <= hue <= 1
vec3 hue_to_rgb_v1(float hue) {
	vec3 offset = vec3(2.0, 0.0, 4.0);
	vec3 v = mod(6.0 * hue + offset, 6.0);
	vec3 color = clamp(min(v, 4.0 - v), 0.0, 1.0);
	return color / (color.r + color.g + color.b);
}

const mat3 HUE_TO_MAX_CIRCLE = mat3(
	vec3(0.5, -0.25, -0.25),
	vec3(0.0, sqrt(3.0)/4.0, -sqrt(3.0)/4.0),
	vec3(0.5, 0.5, 0.5)
);

vec3 hue_to_rgb_v2(float hue) {
	float rad = TAU * hue;
	return HUE_TO_MAX_CIRCLE * vec3(cos(rad), sin(rad), 1.0);
}

vec3 color00(vec2 p) {
	float hue = mod(atan(p.y, p.x), TAU) / TAU;
	return hue_to_rgb_v0(hue);
}

vec3 color01(vec2 p) {
	vec2 p_out = cinv(p);
	float hue = mod(atan(p_out.y, p_out.x), TAU) / TAU;
	return hue_to_rgb_v0(hue);
}

vec3 color02(vec2 p) {
	vec2 p_out = cmul(p, p) + vec2(1.0, 1.0);
	float hue = mod(atan(p_out.y, p_out.x), TAU) / TAU;
	return hue_to_rgb_v0(hue);
}

vec3 color10(vec2 p) {
	float hue = mod(atan(p.y, p.x), TAU) / TAU;
	return hue_to_rgb_v1(hue);
}

vec3 color11(vec2 p) {
	vec2 p_out = cinv(p);
	float hue = mod(atan(p_out.y, p_out.x), TAU) / TAU;
	return hue_to_rgb_v1(hue);
}

vec3 color12(vec2 p) {
	vec2 p_out = cmul(p, p) + vec2(1.0, 1.0);
	float hue = mod(atan(p_out.y, p_out.x), TAU) / TAU;
	return hue_to_rgb_v1(hue);
}

vec3 color20(vec2 p) {
	float hue = mod(atan(p.y, p.x), TAU) / TAU;
	return hue_to_rgb_v2(hue);
}

vec3 color21(vec2 p) {
	vec2 p_out = cinv(p);
	float hue = mod(atan(p_out.y, p_out.x), TAU) / TAU;
	return hue_to_rgb_v2(hue);
}

vec3 color22(vec2 p) {
	vec2 p_out = cmul(p, p) + vec2(1.0, 1.0);
	float hue = mod(atan(p_out.y, p_out.x), TAU) / TAU;
	return hue_to_rgb_v2(hue);
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
