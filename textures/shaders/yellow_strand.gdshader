shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 input_color = texture(TEXTURE, UV);
	bool mostly_green = (input_color.g > input_color.r) && (input_color.g > input_color.b) && (input_color.a != 0.0);
	
	vec4 yellow = vec4(0.929, 0.882, 0.62, 1.0);
	
	if (mostly_green) {;
		COLOR = mix(input_color, yellow, 0.7);
		//COLOR = vec4(0.0, 1.0, 1.0, 1.0);
	}
	
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
