shader_type spatial;
// Polished steel with engraved grooves, like a petanque boule ("striée"), so you can see the ball rolling.
// The grooves live in the ball's own space, so they rotate with it.

uniform vec3 albedo : source_color = vec3(0.86, 0.87, 0.9);
uniform vec3 groove_color : source_color = vec3(0.18, 0.18, 0.2);
uniform float metallic : hint_range(0.0, 1.0) = 0.85;
uniform float roughness : hint_range(0.0, 1.0) = 0.25;
uniform float groove_roughness : hint_range(0.0, 1.0) = 0.8;
// Groove width as a share of the radius.
uniform float groove_width : hint_range(0.005, 0.2) = 0.05;
// Three parallel rings per set: the equator plus two at this height (share of the radius).
uniform float ring_offset : hint_range(0.0, 0.9) = 0.45;

varying vec3 local_direction;

void vertex() {
	local_direction = VERTEX;
}

// 1 inside a groove centred where `d` = 0, 0 outside, with an anti-aliased edge.
float groove(float d) {
	float edge = fwidth(d);
	return 1.0 - smoothstep(groove_width * 0.5, groove_width * 0.5 + edge, abs(d));
}

float ring_set(float d) {
	return max(groove(d), max(groove(d - ring_offset), groove(d + ring_offset)));
}

void fragment() {
	vec3 p = normalize(local_direction);
	// Two sets of rings around perpendicular axes, like the cross-hatched bands on a petanque ball.
	float g = max(ring_set(p.y), ring_set(p.x));
	ALBEDO = mix(albedo, groove_color, g);
	METALLIC = mix(metallic, 0.4, g);
	ROUGHNESS = mix(roughness, groove_roughness, g);
}
