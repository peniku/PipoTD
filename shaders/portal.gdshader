// Redemoinho mágico do portal de onde saem os inimigos.
// Usado em scripts/visual/world_builder.gd. Ver docs/art-direction.md.
shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never;

uniform vec4 color_a : source_color = vec4(0.45, 0.08, 0.85, 1.0);
uniform vec4 color_b : source_color = vec4(0.10, 0.85, 0.55, 1.0);
uniform float speed = 0.6;
uniform float intensity = 1.6;

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	float r = length(uv);
	float a = atan(uv.y, uv.x);
	float s1 = sin(a * 5.0 + r * 11.0 - TIME * speed * 6.0) * 0.5 + 0.5;
	float s2 = sin(a * 3.0 - r * 15.0 + TIME * speed * 4.0) * 0.5 + 0.5;
	float mask = smoothstep(1.0, 0.7, r);
	float core = smoothstep(0.45, 0.0, r);
	vec3 col = mix(color_a.rgb, color_b.rgb, s2 * 0.6) * (0.35 + s1 * 1.2);
	col += color_a.rgb * core * 0.8;
	ALBEDO = col * mask * intensity * (1.15 - r * 0.5);
}
