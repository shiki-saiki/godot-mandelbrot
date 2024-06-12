shader_type canvas_item;

float normal_distrib(float x) {
	return exp(x*x/-2.0) / sqrt(TAU);
}

float normal_distrib_v2(float x) {
	return exp(-sqrt(TAU)/2.0 * x * x);
}

void vertex() {
	
}

void fragment() {
	float scale = 4.0;
	vec2 p = (UV - vec2(0.5, 0.5)) * scale;
	COLOR.rgb = vec3(normal_distrib_v2(length(p)));
}
