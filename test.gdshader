shader_type canvas_item;

uniform float blue = 0.5;
uniform sampler2D image: source_color;

void vertex() {
	//if (VERTEX.x == -64.0 && VERTEX.y == -64.0) {
		//VERTEX.x += cos(TIME * TAU * 0.5) * 70.0;
		//VERTEX.y += sin(TIME * TAU * 0.5) * 70.0;
	//}
}

void fragment() {
	ivec2 size = textureSize(TEXTURE, 0);
	float x = float(size.x) * UV.x;
	float y = float(size.y) * UV.y;
	COLOR = texture(image, UV + vec2(0.02));
	//COLOR = texture(TEXTURE, mod(UV * (cos(TIME * TAU * 0.5) + 1.0) * 2.0, 1.0));
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
