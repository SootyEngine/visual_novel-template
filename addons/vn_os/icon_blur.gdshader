shader_type canvas_item;

uniform float blur : hint_range(0.0, 8.0) = 1.0;

void fragment() {
	COLOR = textureLod(TEXTURE, UV, blur);
}
