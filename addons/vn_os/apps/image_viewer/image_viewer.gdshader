shader_type canvas_item;

void fragment() {
	// use screen uv so it's obvious when we move around
	vec2 uv = SCREEN_UV * 80.0;
	// fix for aspect ration
	uv.y *= SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	// get a checker pattern
	float checker = floor(uv.x) + floor(uv.y);
	checker = fract(checker * 0.5);
	// brighten
	checker += 0.8;
	COLOR.rgb = vec3(checker);
}
