shader_type spatial;

render_mode cull_disabled; // To make plane visible from both sides
render_mode unshaded; // To prevent shader being effected by lighting


uniform sampler2D cell_lines_noise: source_color;
uniform vec3 color: source_color = vec3(1);
uniform float horiz_lines_freq = 500.0;
uniform float horiz_lines_speed = 2.0;
uniform float pulse_speed = 1.0;
uniform float pulse_min = 0.6;
uniform float alpha_min = 0.05;
uniform float edge_fade_strength = 40.0;
uniform float uv_scale = 0.15;
varying vec2 world_uv;


void vertex() {
	// Scale world_uv down by multiplying by uv_scale. This changes the "size" of the texture on the mesh
	world_uv = VERTEX.zx * uv_scale;
}
    

void fragment() {
	// Cell lines
	// The texture is black and white. Only need a value from 0.0 to 1.0. So just taking the blue (.b) value
	float cell_lines = texture(cell_lines_noise, world_uv).b;
	
	// Horizontal lines
	float horiz_lines = sin(UV.y * horiz_lines_freq + (TIME * horiz_lines_speed));
	horiz_lines = (horiz_lines + 1.0) * 0.5; // Shifting the values of sin to all be positive and between 0 and 1
	
	
	// Edge fade
	float edge_fade_right = pow(UV.x, edge_fade_strength);
	float edge_fade_left = pow(1.0 - UV.x, edge_fade_strength); // 1.0 - UV. to flip the right fade to the left
	float edge_fade = edge_fade_right + edge_fade_left;
	edge_fade = clamp(edge_fade, 0.0, 1.0); // Prevent values out of these bounds from effecting the rest of the shader.
	
	
	// Pulse
	float pulse_strength = sin(TIME * pulse_speed);
	pulse_strength = (pulse_strength + 1.0) * 0.5; // Shifting the values of sin to all be positive and between 0 and 1
	// Mix same as lerp. Interpolating value between 1.0 and the minimum where pulse_strength is the factor.
	float pulse = mix(1.0, pulse_min, pulse_strength);
	
	
	// Alpha mix
	float alpha_mask = (cell_lines * horiz_lines) + edge_fade;
	alpha_mask = max(alpha_mask, alpha_min); // Setting a minimum value so there is always at least a small tint of color
	
	
	ALPHA = alpha_mask * pulse; // All variation controlled in the alpha channel
	ALBEDO = color;
}
