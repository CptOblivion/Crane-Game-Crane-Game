shader_type canvas_item;

uniform vec2 CamPos;

void vertex() {
	vec2 offs = vec2(CamPos.x * COLOR.x * 2.0, CamPos.y * COLOR.y * 2.0);
	vec2 origin = VERTEX.xy;
	VERTEX.x = origin.x + offs.x;
	VERTEX.y = origin.y + offs.y;
}

void fragment() {
	// texture sample here
	// or UV to color gradient
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
