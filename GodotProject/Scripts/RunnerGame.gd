extends Node3D

const LANES := [-2.4, 0.0, 2.4]
const SEGMENT_LENGTH := 24.0
const SEGMENT_COUNT := 7
const FORWARD_SPEED := 10.0

var player: CharacterBody3D
var camera: Camera3D
var world_root: Node3D
var hud: CanvasLayer
var lane := 1
var distance_m := 0.0
var coins := 0
var score := 0
var game_over := false
var swipe_start := Vector2.ZERO
var segments: Array[Node3D] = []
var status_label: Label
var score_label: Label
var touch_hint: Label

func _ready() -> void:
	_build_world()
	_build_player()
	_build_camera()
	_build_hud()
	for i in range(SEGMENT_COUNT):
		_add_segment(-float(i) * SEGMENT_LENGTH)
	_update_hud()

func _process(delta: float) -> void:
	if game_over:
		return
	distance_m += FORWARD_SPEED * delta
	score = int(distance_m) + coins * 10
	player.position.z -= FORWARD_SPEED * delta
	camera.position = camera.position.lerp(player.position + Vector3(0, 5.5, 9.5), delta * 4.0)
	camera.look_at(player.position + Vector3(0, 1.0, -5.0), Vector3.UP)
	_recycle_segments()
	_update_hud()

func _unhandled_input(event: InputEvent) -> void:
	if game_over:
		if event is InputEventScreenTouch and event.pressed:
			get_tree().reload_current_scene()
		elif event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
			get_tree().reload_current_scene()
		return
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_LEFT, KEY_A: _change_lane(-1)
			KEY_RIGHT, KEY_D: _change_lane(1)
			KEY_UP, KEY_W, KEY_SPACE: _jump()
			KEY_DOWN, KEY_S: _slide()
	if event is InputEventScreenTouch:
		if event.pressed:
			swipe_start = event.position
		else:
			var swipe := event.position - swipe_start
			if swipe.length() > 35:
				if abs(swipe.x) > abs(swipe.y):
					_change_lane(1 if swipe.x < 0 else -1)
				elif swipe.y < 0:
					_jump()
				else:
					_slide()

func _build_world() -> void:
	world_root = Node3D.new()
	world_root.name = "EndlessBangladeshWorld"
	add_child(world_root)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -25, 0)
	sun.light_energy = 1.2
	world_root.add_child(sun)
	var env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.sky = Sky.new()
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.65, 0.75, 0.82)
	environment.ambient_light_energy = 0.7
	env.environment = environment
	world_root.add_child(env)

func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(0, 0.95, 0)
	add_child(player)
	var body := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.42
	capsule.height = 1.8
	body.mesh = capsule
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.12, 0.25, 0.72)
	body.material_override = material
	player.add_child(body)
	var head := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.27
	sphere.height = 0.54
	head.mesh = sphere
	head.position.y = 0.92
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.72, 0.48, 0.32)
	head.material_override = skin
	player.add_child(head)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.position = Vector3(0, 5.5, 9.5)
	camera.fov = 72
	add_child(camera)
	camera.current = true
	camera.look_at(Vector3(0, 1, -5), Vector3.UP)

func _build_hud() -> void:
	hud = CanvasLayer.new()
	add_child(hud)
	var panel := ColorRect.new()
	panel.color = Color(0.02, 0.08, 0.12, 0.72)
	panel.position = Vector2(14, 14)
	panel.size = Vector2(390, 112)
	hud.add_child(panel)
	score_label = Label.new()
	score_label.position = Vector2(28, 20)
	score_label.add_theme_font_size_override("font_size", 25)
	panel.add_child(score_label)
	status_label = Label.new()
	status_label.position = Vector2(28, 58)
	status_label.add_theme_font_size_override("font_size", 18)
	panel.add_child(status_label)
	touch_hint = Label.new()
	touch_hint.text = "Swipe: বামে / ডানে • উপরে লাফ • নিচে স্লাইড"
	touch_hint.position = Vector2(12, 1160)
	touch_hint.add_theme_font_size_override("font_size", 17)
	touch_hint.add_theme_color_override("font_color", Color.WHITE)
	hud.add_child(touch_hint)

func _add_segment(z_pos: float) -> void:
	var segment := Node3D.new()
	segment.position.z = z_pos
	world_root.add_child(segment)
	segments.append(segment)
	_box(segment, Vector3(8.2, 0.18, SEGMENT_LENGTH), Vector3(0, -0.18, -SEGMENT_LENGTH * 0.5), Color(0.18, 0.2, 0.19))
	_box(segment, Vector3(1.0, 0.12, SEGMENT_LENGTH), Vector3(-4.6, -0.2, -SEGMENT_LENGTH * 0.5), Color(0.25, 0.55, 0.2))
	_box(segment, Vector3(1.0, 0.12, SEGMENT_LENGTH), Vector3(4.6, -0.2, -SEGMENT_LENGTH * 0.5), Color(0.25, 0.55, 0.2))
	_box(segment, Vector3(0.12, 0.025, SEGMENT_LENGTH), Vector3(-1.2, -0.075, -SEGMENT_LENGTH * 0.5), Color(0.9, 0.85, 0.55))
	_box(segment, Vector3(0.12, 0.025, SEGMENT_LENGTH), Vector3(1.2, -0.075, -SEGMENT_LENGTH * 0.5), Color(0.9, 0.85, 0.55))
	_add_field_props(segment, z_pos)

func _add_field_props(segment: Node3D, z_pos: float) -> void:
	for side in [-1, 1]:
		for i in range(3):
			var tree := MeshInstance3D.new()
			var trunk := CylinderMesh.new()
			trunk.top_radius = 0.12
			trunk.bottom_radius = 0.18
			trunk.height = 1.5
			tree.mesh = trunk
			tree.position = Vector3(float(side) * (6.0 + float(i % 2)), 0.65, -3.0 - float(i) * 7.0)
			var trunk_mat := StandardMaterial3D.new()
			trunk_mat.albedo_color = Color(0.32, 0.2, 0.1)
			tree.material_override = trunk_mat
			segment.add_child(tree)
			var crown := MeshInstance3D.new()
			var crown_mesh := SphereMesh.new()
			crown_mesh.radius = 0.85
			crown_mesh.height = 1.5
			crown.mesh = crown_mesh
			crown.position = tree.position + Vector3(0, 1.15, 0)
			var leaf := StandardMaterial3D.new()
			leaf.albedo_color = Color(0.12, 0.42, 0.16)
			crown.material_override = leaf
			segment.add_child(crown)
	# Distant green paddy-field strips
	_box(segment, Vector3(18, 0.08, SEGMENT_LENGTH), Vector3(-14, -0.22, -SEGMENT_LENGTH * 0.5), Color(0.25, 0.48, 0.16))
	_box(segment, Vector3(18, 0.08, SEGMENT_LENGTH), Vector3(14, -0.22, -SEGMENT_LENGTH * 0.5), Color(0.25, 0.48, 0.16))
	if int(abs(z_pos) / SEGMENT_LENGTH) % 3 == 1:
		_box(segment, Vector3(2.2, 2.5, 2.0), Vector3(-7.0, 1.15, -12), Color(0.72, 0.55, 0.32))
		_box(segment, Vector3(2.2, 2.5, 2.0), Vector3(7.0, 1.15, -5), Color(0.65, 0.42, 0.28))
	if int(abs(z_pos) / SEGMENT_LENGTH) % 2 == 0:
		_add_coin(segment, Vector3(LANES[randi_range(0, 2)], 1.0, -15.0))
	else:
		_add_obstacle(segment, Vector3(LANES[randi_range(0, 2)], 0.65, -16.0))

func _box(parent: Node3D, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	item.mesh = mesh
	item.position = pos
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	item.material_override = mat
	parent.add_child(item)
	return item

func _add_coin(parent: Node3D, pos: Vector3) -> void:
	var coin := Area3D.new()
	coin.position = pos
	coin.set_meta("kind", "coin")
	var mesh := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.38
	cylinder.bottom_radius = 0.38
	cylinder.height = 0.12
	mesh.mesh = cylinder
	mesh.rotation_degrees.x = 90
	var gold := StandardMaterial3D.new()
	gold.albedo_color = Color(1.0, 0.72, 0.08)
	gold.metallic = 0.65
	mesh.material_override = gold
	coin.add_child(mesh)
	var collision := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.65
	collision.shape = shape
	coin.add_child(collision)
	coin.body_entered.connect(func(body: Node3D):
		if body == player:
			coins += 1
			coin.queue_free()
	)
	parent.add_child(coin)

func _add_obstacle(parent: Node3D, pos: Vector3) -> void:
	var obstacle := Area3D.new()
	obstacle.position = pos
	var mesh := MeshInstance3D.new()
	var block := BoxMesh.new()
	block.size = Vector3(1.25, 1.3, 1.0)
	mesh.mesh = block
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.78, 0.22, 0.12)
	mesh.material_override = mat
	obstacle.add_child(mesh)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.35, 1.4, 1.1)
	collision.shape = shape
	obstacle.add_child(collision)
	obstacle.body_entered.connect(func(body: Node3D):
		if body == player:
			_end_game()
	)
	parent.add_child(obstacle)

func _change_lane(direction: int) -> void:
	lane = clampi(lane + direction, 0, 2)
	var tween := create_tween()
	tween.tween_property(player, "position:x", LANES[lane], 0.16)

func _jump() -> void:
	var tween := create_tween()
	tween.tween_property(player, "position:y", 2.1, 0.18)
	tween.tween_property(player, "position:y", 0.95, 0.32)

func _slide() -> void:
	var tween := create_tween()
	tween.tween_property(player, "scale:y", 0.55, 0.1)
	tween.tween_property(player, "scale:y", 1.0, 0.35)

func _recycle_segments() -> void:
	for segment in segments:
		if segment.global_position.z > player.position.z + SEGMENT_LENGTH:
			segment.queue_free()
			segments.erase(segment)
			var farthest := -24.0
			for other in segments:
				farthest = minf(farthest, other.position.z)
			_add_segment(farthest - SEGMENT_LENGTH)
			break

func _update_hud() -> void:
	score_label.text = "JIBON RUNNER   |   স্কোর: %d\nকয়েন: %d" % [score, coins]
	status_label.text = "দূরত্ব: %.0f মিটার" % distance_m
	if int(distance_m) >= 5000 and int(distance_m) < 5010:
		status_label.text = "৫ কিমি! সকালের নাস্তার বিরতি সামনে"

func _end_game() -> void:
	game_over = true
	status_label.text = "গেম শেষ! স্কোর: %d\nআবার খেলতে টাচ করুন" % score
	touch_hint.text = "আবার শুরু করতে স্ক্রিনে টাচ করুন"
