shader_type canvas_item;

uniform vec2 cam_pos;

uniform vec4 color_1: source_color = vec4(1.0);
uniform vec4 color_2: source_color = vec4(1.0);

float lerp1(float a, float b, float t) {
	return a * (1.0 - t) + b * t;
}

vec2 lerp2(vec2 a, vec2 b, float t) {
	return a * (1.0 - t) + b * t;
}

vec4 lerp4(vec4 a, vec4 b, float t) {
	return a * (1.0 - t) + b * t;
}

void vertex() {
	vec2 local_cam_pos = (inverse(MODEL_MATRIX) * vec4(cam_pos, 0.0, 1.0)).xy;
 	float dist = 1.0 - COLOR.x * 2.0;
	VERTEX = lerp2(VERTEX, local_cam_pos, dist);
}

void fragment() {
	float t = UV.y;
	COLOR = lerp4(color_1, color_2, UV.y);
}
