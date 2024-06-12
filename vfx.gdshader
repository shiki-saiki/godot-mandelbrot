shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;

vec4 color_invert(vec4 c) {
	return abs(vec4(1.0, 1.0, 1.0, 0.0) - c);
}

vec4 color_invert_lightness(vec4 c) {
	float l = (c.r + c.g + c.b) / 3.0;
	return c * (1.0 - l);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = color_invert(texture(screen_texture, SCREEN_UV));
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
