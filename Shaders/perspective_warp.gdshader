shader_type canvas_item;

uniform vec2 cam_pos;

uniform vec4 color_1: source_color = vec4(1.0);
uniform vec4 color_2: source_color = vec4(1.0);

void vertex() {
	float scrollStrength = 1.0 - COLOR.x * 2.0;
	vec2 offs = cam_pos * scrollStrength;
	vec2 origin = VERTEX.xy;
	VERTEX.x = origin.x + offs.x;
	VERTEX.y = origin.y + offs.y;
}

void fragment() {
	float t = UV.y;
	COLOR = color_1 * (1.0-t) + color_2 * t;
}
