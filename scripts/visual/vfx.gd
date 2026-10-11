class_name VFX
extends RefCounted
## Efeitos visuais de curta duração: explosões de partículas, clarões de luz,
## anel de onda de choque e números de ouro flutuando. Cada efeito se apaga
## sozinho. Só visual. Ver docs/art-direction.md.


## Explosão de partículas + clarão de luz. radius > 0 adiciona onda de choque.
static func impact(parent: Node, pos: Vector3, color: Color, radius: float = 0.0, amount: int = 14) -> void:
	if parent == null or not parent.is_inside_tree():
		return
	var p := GPUParticles3D.new()
	p.one_shot = true
	p.amount = amount
	p.lifetime = 0.6
	p.explosiveness = 0.95
	p.draw_pass_1 = Art.soft_dot_mesh()
	var pm := ParticleProcessMaterial.new()
	pm.direction = Vector3.UP
	pm.spread = 180.0
	pm.initial_velocity_min = 1.5 + radius
	pm.initial_velocity_max = 3.5 + radius * 1.5
	pm.gravity = Vector3(0, -4, 0)
	pm.damping_min = 2.0
	pm.damping_max = 4.0
	pm.scale_min = 0.12
	pm.scale_max = 0.3
	pm.color = color * 2.0
	pm.color_ramp = Art._alpha_fade()
	p.process_material = pm
	parent.add_child(p)
	p.global_position = pos
	p.emitting = true

	var l := OmniLight3D.new()
	l.light_color = color
	l.light_energy = 3.0
	l.omni_range = 2.5 + radius * 1.5
	parent.add_child(l)
	l.global_position = pos + Vector3.UP * 0.5
	var tw := l.create_tween()
	tw.tween_property(l, "light_energy", 0.0, 0.35)
	tw.tween_callback(l.queue_free)

	if radius > 0.0:
		var ring := MeshInstance3D.new()
		var torus := TorusMesh.new()
		torus.inner_radius = 0.85
		torus.outer_radius = 1.0
		torus.rings = 32
		torus.ring_segments = 4
		ring.mesh = torus
		var m := StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		m.albedo_color = color
		ring.material_override = m
		parent.add_child(ring)
		ring.global_position = Vector3(pos.x, 0.15, pos.z)
		ring.scale = Vector3.ONE * 0.2
		var tr := ring.create_tween()
		tr.set_parallel(true)
		tr.tween_property(ring, "scale", Vector3(radius, 0.4, radius), 0.35)
		tr.tween_property(m, "albedo_color:a", 0.0, 0.4)
		tr.chain().tween_callback(ring.queue_free)

	parent.get_tree().create_timer(1.2).timeout.connect(p.queue_free)


## Texto flutuante (ex.: "+5" de ouro) que sobe e some.
static func float_text(parent: Node, pos: Vector3, text: String, color: Color) -> void:
	if parent == null or not parent.is_inside_tree():
		return
	var l := Label3D.new()
	l.text = text
	l.font_size = 56
	l.pixel_size = 0.008
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.modulate = color
	l.outline_size = 10
	l.outline_modulate = Color(0.1, 0.05, 0.0, 0.9)
	l.font = HUD.serif_font()
	parent.add_child(l)
	l.global_position = pos
	var tw := l.create_tween()
	tw.set_parallel(true)
	tw.tween_property(l, "global_position", pos + Vector3.UP * 1.4, 0.9)
	tw.tween_property(l, "modulate:a", 0.0, 0.9).set_delay(0.3)
	tw.tween_property(l, "outline_modulate:a", 0.0, 0.9).set_delay(0.3)
	tw.chain().tween_callback(l.queue_free)
