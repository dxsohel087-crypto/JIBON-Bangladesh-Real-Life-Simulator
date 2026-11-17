extends Node3D

const LANES: Array[float] = [-2.4, 0.0, 2.4]
const SEGMENT_LENGTH := 24.0
const SEGMENT_COUNT := 7
const FORWARD_SPEED := 10.0
const PLAYER_BASE_Y := 0.95

var player: CharacterBody3D
var camera: Camera3D
var world_root: Node3D
var hud: CanvasLayer
var lane := 1
var distance_m := 0.0
var coins := 0
var score := 0
var game_over := false
var paused := false
var best_score := 0
var total_coins := 0
var pause_button: Button
var pause_overlay: ColorRect
var best_label: Label
var left_arm: MeshInstance3D
var right_arm: MeshInstance3D
var left_leg: MeshInstance3D
var right_leg: MeshInstance3D
var run_clock := 0.0
var menu_heading: Label
var resume_button: Button
var restart_button: Button
var break_active := false
var breaks_reached: Array[int] = []
var sun_light: DirectionalLight3D
var world_environment: WorldEnvironment
var day_clock := 0.0
var break_scene: Node3D
var shop_button: Button
var mission_button: Button
var daily_button: Button
var player_body: MeshInstance3D
var skin_index := 0
var daily_claim_day := 0
var swipe_start := Vector2.ZERO
var segments: Array[Node3D] = []
var coin_nodes: Array[Area3D] = []
var obstacle_nodes: Array[Area3D] = []
var jump_time := 0.0
var slide_time := 0.0
var status_label: Label
var score_label: Label
var touch_hint: Label

func _ready() -> void:
	randomize()
	_load_progress()
	_build_world()
	_build_player()
	_build_camera()
	_build_hud()
	for i in range(SEGMENT_COUNT):
		_add_segment(-float(i) * SEGMENT_LENGTH)
	_update_hud()

func _process(delta: float) -> void:
	if game_over or paused:
		return
	distance_m += FORWARD_SPEED * delta
	_update_day_night(delta)
	_check_distance_breaks()
	if paused:
		return
	score = int(distance_m) + coins * 10
	player.position.z -= FORWARD_SPEED * delta
	_update_player_actions(delta)
	camera.position = camera.position.lerp(player.position + Vector3(0, 5.5, 9.5), minf(delta * 4.0, 1.0))
	camera.look_at(player.position + Vector3(0, 1.0, -5.0), Vector3.UP)
	_recycle_segments()
	_check_pickups_and_obstacles()
	_update_hud()

func _update_player_actions(delta: float) -> void:
	run_clock += delta * 12.0
	if jump_time > 0.0:
		jump_time = maxf(0.0, jump_time - delta)
		var progress := 1.0 - jump_time / 0.58
		player.position.y = PLAYER_BASE_Y + sin(progress * PI) * 1.35
	else:
		player.position.y = PLAYER_BASE_Y
	if slide_time > 0.0:
		slide_time = maxf(0.0, slide_time - delta)
		player.scale.y = 0.55
	else:
		player.scale.y = 1.0
	var swing := sin(run_clock) * (0.48 if jump_time <= 0.0 and slide_time <= 0.0 else 0.12)
	left_arm.rotation.x = swing
	right_arm.rotation.x = -swing
	left_leg.rotation.x = -swing
	right_leg.rotation.x = swing

func _unhandled_input(event: InputEvent) -> void:
	if game_over or paused:
		if event is InputEventKey and event.pressed and event.keycode == KEY_P:
			_toggle_pause()
		elif game_over and event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_SPACE]:
			get_tree().reload_current_scene()
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		_toggle_pause()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_LEFT, KEY_A: _change_lane(-1)
			KEY_RIGHT, KEY_D: _change_lane(1)
			KEY_UP, KEY_W, KEY_SPACE: _jump()
			KEY_DOWN, KEY_S: _slide()
	if event is InputEventScreenTouch:
		if event.pressed:
			swipe_start = event.position
		else:
			var swipe: Vector2 = event.position - swipe_start
			if swipe.length() > 35.0:
				if absf(swipe.x) > absf(swipe.y):
					_change_lane(1 if swipe.x > 0.0 else -1)
				elif swipe.y < 0.0:
					_jump()
				else:
					_slide()

func _build_world() -> void:
	world_root = Node3D.new()
	world_root.name = "EndlessBangladeshWorld"
	add_child(world_root)
	sun_light = DirectionalLight3D.new()
	sun_light.rotation_degrees = Vector3(-48, -25, 0)
	sun_light.light_energy = 1.2
	world_root.add_child(sun_light)
	world_environment = WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.sky = Sky.new()
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.65, 0.75, 0.82)
	environment.ambient_light_energy = 0.7
	world_environment.environment = environment
	world_root.add_child(world_environment)

func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(0, PLAYER_BASE_Y, 0)
	add_child(player)
	player_body = MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.42
	capsule.height = 1.8
	player_body.mesh = capsule
	var material := StandardMaterial3D.new()
	material.albedo_color = _skin_color()
	player_body.material_override = material
	player.add_child(player_body)
	var player_collision := CollisionShape3D.new()
	var player_shape := CapsuleShape3D.new()
	player_shape.radius = 0.42
	player_shape.height = 1.8
	player_collision.shape = player_shape
	player.add_child(player_collision)
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

	left_arm = _make_limb(Vector3(0.48, 0.18, 0), 0.14, 0.72, Color(0.1, 0.22, 0.62))
	right_arm = _make_limb(Vector3(-0.48, 0.18, 0), 0.14, 0.72, Color(0.1, 0.22, 0.62))
	left_leg = _make_limb(Vector3(0.2, -0.68, 0), 0.16, 0.72, Color(0.08, 0.08, 0.1))
	right_leg = _make_limb(Vector3(-0.2, -0.68, 0), 0.16, 0.72, Color(0.08, 0.08, 0.1))

func _make_limb(pos: Vector3, radius: float, height: float, color: Color) -> MeshInstance3D:
	var limb := MeshInstance3D.new()
	var shape := CapsuleMesh.new()
	shape.radius = radius
	shape.height = height
	limb.mesh = shape
	limb.position = pos
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	limb.material_override = mat
	player.add_child(limb)
	return limb

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.position = Vector3(0, 5.5, 9.5)
	camera.fov = 72.0
	add_child(camera)
	camera.current = true
	camera.look_at(Vector3(0, 1, -5), Vector3.UP)

func _build_hud() -> void:
	hud = CanvasLayer.new()
	add_child(hud)
	var panel := ColorRect.new()
	panel.color = Color(0.02, 0.08, 0.12, 0.78)
	panel.position = Vector2(14, 14)
	panel.size = Vector2(310, 112)
	hud.add_child(panel)
	score_label = Label.new()
	score_label.position = Vector2(14, 10)
	score_label.add_theme_font_size_override("font_size", 23)
	panel.add_child(score_label)
	status_label = Label.new()
	status_label.position = Vector2(14, 62)
	status_label.add_theme_font_size_override("font_size", 17)
	panel.add_child(status_label)
	best_label = Label.new()
	best_label.position = Vector2(14, 86)
	best_label.add_theme_font_size_override("font_size", 14)
	panel.add_child(best_label)

	pause_button = Button.new()
	pause_button.text = "Ⅱ"
	pause_button.position = Vector2(-76, 14)
	pause_button.size = Vector2(62, 54)
	pause_button.set_anchors_preset(Control.PRESET_TOP_RIGHT, true)
	pause_button.add_theme_font_size_override("font_size", 25)
	pause_button.pressed.connect(_toggle_pause)
	hud.add_child(pause_button)

	touch_hint = Label.new()
	touch_hint.text = "Swipe ← → lane  •  ↑ jump  •  ↓ slide"
	touch_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	touch_hint.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	touch_hint.offset_left = 8
	touch_hint.offset_top = -48
	touch_hint.offset_right = -8
	touch_hint.offset_bottom = -12
	touch_hint.add_theme_font_size_override("font_size", 16)
	touch_hint.add_theme_color_override("font_color", Color.WHITE)
	hud.add_child(touch_hint)

	pause_overlay = ColorRect.new()
	pause_overlay.color = Color(0.01, 0.03, 0.06, 0.82)
	pause_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_overlay.visible = false
	hud.add_child(pause_overlay)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_overlay.add_child(center)
	var menu := VBoxContainer.new()
	menu.add_theme_constant_override("separation", 16)
	menu.custom_minimum_size = Vector2(260, 0)
	center.add_child(menu)
	menu_heading = Label.new()
	menu_heading.text = "JIBON RUNNER"
	menu_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_heading.add_theme_font_size_override("font_size", 30)
	menu.add_child(menu_heading)
	resume_button = Button.new()
	resume_button.text = "খেলা চালিয়ে যান"
	resume_button.custom_minimum_size = Vector2(260, 58)
	resume_button.pressed.connect(_resume_game)
	menu.add_child(resume_button)
	restart_button = Button.new()
	restart_button.text = "আবার শুরু"
	restart_button.custom_minimum_size = Vector2(260, 58)
	restart_button.pressed.connect(func(): get_tree().reload_current_scene())
	menu.add_child(restart_button)
	shop_button = Button.new()
	shop_button.text = "চরিত্রের পোশাকের দোকান"
	shop_button.custom_minimum_size = Vector2(260, 48)
	shop_button.pressed.connect(_open_shop)
	menu.add_child(shop_button)
	mission_button = Button.new()
	mission_button.text = "মিশন ও লক্ষ্য"
	mission_button.custom_minimum_size = Vector2(260, 48)
	mission_button.pressed.connect(_show_missions)
	menu.add_child(mission_button)
	daily_button = Button.new()
	daily_button.text = "দৈনিক পুরস্কার"
	daily_button.custom_minimum_size = Vector2(260, 48)
	daily_button.pressed.connect(_claim_daily_reward)
	menu.add_child(daily_button)

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
	# Roadside paddy plots and irrigation channels
	for side in [-1, 1]:
		_box(segment, Vector3(15.0, 0.06, SEGMENT_LENGTH), Vector3(float(side) * 13.0, -0.25, -SEGMENT_LENGTH * 0.5), Color(0.18, 0.42, 0.12))
		_box(segment, Vector3(0.7, 0.035, SEGMENT_LENGTH), Vector3(float(side) * 7.3, -0.20, -SEGMENT_LENGTH * 0.5), Color(0.18, 0.48, 0.55))
		for row in range(5):
			for plant in range(5):
				var crop := MeshInstance3D.new()
				var blade := CylinderMesh.new()
				blade.top_radius = 0.025
				blade.bottom_radius = 0.07
				blade.height = 0.48
				crop.mesh = blade
				crop.position = Vector3(float(side) * (8.5 + float(plant) * 0.72), 0.12, -1.5 - float(row) * 4.2)
				crop.rotation.z = randf_range(-0.18, 0.18)
				var crop_mat := StandardMaterial3D.new()
				crop_mat.albedo_color = Color(0.22 + randf() * 0.12, 0.48 + randf() * 0.18, 0.12)
				crop.material_override = crop_mat
				segment.add_child(crop)
		for i in range(2):
			var trunk := _box(segment, Vector3(0.28, 1.5, 0.28), Vector3(float(side) * (6.2 + float(i) * 1.0), 0.55, -4.0 - float(i) * 12.0), Color(0.32, 0.2, 0.1))
			var crown := MeshInstance3D.new()
			var crown_mesh := SphereMesh.new()
			crown_mesh.radius = 0.95
			crown_mesh.height = 1.55
			crown.mesh = crown_mesh
			crown.position = trunk.position + Vector3(0, 1.1, 0)
			var leaf := StandardMaterial3D.new()
			leaf.albedo_color = Color(0.10, 0.34 + randf() * 0.12, 0.13)
			crown.material_override = leaf
			segment.add_child(crown)

	var zone := int(absf(z_pos) / SEGMENT_LENGTH) % 5
	if zone == 1:
		# Village houses with bright tin roofs
		for side in [-1, 1]:
			var x := float(side) * 8.5
			_box(segment, Vector3(2.8, 2.2, 3.0), Vector3(x, 0.95, -10.0), Color(0.78, 0.62, 0.39))
			_box(segment, Vector3(3.1, 0.22, 3.3), Vector3(x, 2.15, -10.0), Color(0.35, 0.43, 0.48))
	elif zone == 2:
		# Small roadside bazaar stalls
		for side in [-1, 1]:
			var x := float(side) * 8.0
			_box(segment, Vector3(2.8, 0.16, 2.4), Vector3(x, 1.0, -11.0), Color(0.42, 0.25, 0.12))
			_box(segment, Vector3(3.0, 0.16, 2.6), Vector3(x, 2.15, -11.0), Color(0.78, 0.18 if side == -1 else 0.25, 0.12))
			for post_x in [-1.25, 1.25]:
				_box(segment, Vector3(0.10, 2.0, 0.10), Vector3(x + post_x, 1.0, -11.0), Color(0.25, 0.18, 0.1))
	elif zone == 3:
		# Pond and a simple concrete culvert
		_box(segment, Vector3(7.0, 0.04, 8.0), Vector3(-10.0, -0.12, -12.0), Color(0.12, 0.42, 0.58))
		_box(segment, Vector3(4.0, 0.22, 7.0), Vector3(9.0, 0.0, -12.0), Color(0.52, 0.50, 0.43))
	else:
		# Distant homes on the horizon
		_box(segment, Vector3(2.2, 2.0, 2.2), Vector3(-8.0, 0.9, -15.0), Color(0.70, 0.52, 0.34))
		_box(segment, Vector3(2.2, 2.0, 2.2), Vector3(8.0, 0.9, -6.0), Color(0.66, 0.48, 0.30))

	var pattern := randi_range(0, 3)
	if pattern == 0:
		var coin_lane := randi_range(0, 2)
		for n in range(4):
			_add_coin(segment, Vector3(LANES[coin_lane], 1.0, -7.0 - float(n) * 3.0))
	elif pattern == 1:
		for n in range(3):
			_add_coin(segment, Vector3(LANES[n], 1.0, -12.0))
	else:
		_add_obstacle(segment, Vector3(LANES[randi_range(0, 2)], 0.65, -14.0))

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
	var mesh := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.38
	cylinder.bottom_radius = 0.38
	cylinder.height = 0.12
	mesh.mesh = cylinder
	mesh.rotation_degrees.x = 90.0
	var gold := StandardMaterial3D.new()
	gold.albedo_color = Color(1.0, 0.72, 0.08)
	gold.metallic = 0.65
	mesh.material_override = gold
	coin.add_child(mesh)
	parent.add_child(coin)
	coin_nodes.append(coin)

func _add_obstacle(parent: Node3D, pos: Vector3) -> void:
	var obstacle := Area3D.new()
	obstacle.position = pos
	var obstacle_type := randi_range(0, 2)
	if obstacle_type == 0:
		# Red road barrier
		_box(obstacle, Vector3(1.55, 0.85, 0.28), Vector3(0, 0.15, 0), Color(0.82, 0.20, 0.10))
		for stripe in [-0.48, 0.0, 0.48]:
			_box(obstacle, Vector3(0.18, 0.88, 0.30), Vector3(stripe, 0.15, 0.02), Color(0.95, 0.88, 0.66))
	elif obstacle_type == 1:
		# Wooden produce crates
		_box(obstacle, Vector3(1.15, 1.2, 0.95), Vector3(0, 0.32, 0), Color(0.48, 0.27, 0.12))
		_box(obstacle, Vector3(1.18, 0.12, 0.98), Vector3(0, 0.0, 0), Color(0.62, 0.38, 0.18))
	else:
		# Roadside handcart silhouette
		_box(obstacle, Vector3(1.35, 0.16, 0.85), Vector3(0, 0.45, 0), Color(0.40, 0.24, 0.10))
		_box(obstacle, Vector3(0.12, 0.75, 0.12), Vector3(-0.48, 0.05, 0), Color(0.30, 0.18, 0.08))
		_box(obstacle, Vector3(0.12, 0.75, 0.12), Vector3(0.48, 0.05, 0), Color(0.30, 0.18, 0.08))
	parent.add_child(obstacle)
	obstacle_nodes.append(obstacle)

func _check_pickups_and_obstacles() -> void:
	for coin in coin_nodes.duplicate():
		if not is_instance_valid(coin):
			coin_nodes.erase(coin)
			continue
		var offset: Vector3 = coin.global_position - player.global_position
		if absf(offset.z) < 0.85 and absf(offset.x) < 0.9 and absf(offset.y) < 1.4:
			coins += 1
			total_coins += 1
			_save_progress()
			coin_nodes.erase(coin)
			coin.queue_free()
	for obstacle in obstacle_nodes.duplicate():
		if not is_instance_valid(obstacle):
			obstacle_nodes.erase(obstacle)
			continue
		var offset: Vector3 = obstacle.global_position - player.global_position
		if absf(offset.z) < 0.85 and absf(offset.x) < 0.95:
			var jumped_over := player.position.y > 1.75
			var slid_under := player.scale.y < 0.7
			if not jumped_over and not slid_under:
				_end_game()
				return

func _change_lane(direction: int) -> void:
	lane = clampi(lane + direction, 0, 2)
	var tween := create_tween()
	tween.tween_property(player, "position:x", LANES[lane], 0.16)

func _jump() -> void:
	if jump_time <= 0.0 and slide_time <= 0.0:
		jump_time = 0.58

func _slide() -> void:
	if slide_time <= 0.0 and jump_time <= 0.0:
		slide_time = 0.48

func _recycle_segments() -> void:
	for segment in segments.duplicate():
		if is_instance_valid(segment) and segment.global_position.z > player.position.z + SEGMENT_LENGTH:
			segments.erase(segment)
			segment.queue_free()
			var farthest := 0.0
			for other in segments:
				if is_instance_valid(other):
					farthest = minf(farthest, other.position.z)
			_add_segment(farthest - SEGMENT_LENGTH)
			break

func _update_hud() -> void:
	score_label.text = "স্কোর: %d\nকয়েন: %d" % [score, coins]
	status_label.text = "দূরত্ব: %.0f মিটার" % distance_m
	best_label.text = "সেরা: %d  |  মোট কয়েন: %d" % [best_score, total_coins]
	for milestone in [5000, 10000, 15000, 20000]:
		if distance_m >= float(milestone) and distance_m < float(milestone) + 10.0:
			status_label.text = "%d কিমি অতিক্রম করেছেন!" % int(milestone / 1000)
			break

func _end_game() -> void:
	game_over = true
	best_score = maxi(best_score, score)
	_save_progress()
	status_label.text = "গেম শেষ! স্কোর: %d" % score
	touch_hint.text = "গেম শেষ — আবার শুরু করতে বোতাম চাপুন"
	pause_button.visible = false
	pause_overlay.visible = true
	resume_button.visible = false
	shop_button.visible = false
	mission_button.visible = false
	daily_button.visible = false
	restart_button.text = "আবার খেলুন"
	menu_heading.text = "গেম শেষ!"

func _toggle_pause() -> void:
	if game_over or break_active:
		return
	paused = not paused
	pause_overlay.visible = paused
	pause_button.text = "▶" if paused else "Ⅱ"
	menu_heading.text = "বিরতি" if paused else "JIBON RUNNER"
	resume_button.visible = true

func _resume_game() -> void:
	paused = false
	break_active = false
	if is_instance_valid(break_scene):
		break_scene.queue_free()
	break_scene = null
	pause_overlay.visible = false
	pause_button.text = "Ⅱ"
	menu_heading.text = "JIBON RUNNER"
	resume_button.visible = true
	restart_button.text = "আবার শুরু"
	shop_button.visible = true
	mission_button.visible = true
	daily_button.visible = true

func _check_distance_breaks() -> void:
	var milestones := {
		5000: "৫ কিমি — সকালের নাস্তার বিরতি! 🍞",
		10000: "১০ কিমি — গ্রামের দোকানে খাবারের বিরতি! 🥤",
		15000: "১৫ কিমি — দুপুরের খাবারের বিরতি! 🍚",
		20000: "২০ কিমি — পানি পান করুন, একটু বিশ্রাম নিন! 💧"
	}
	for milestone in milestones.keys():
		if distance_m >= float(milestone) and not breaks_reached.has(milestone):
			breaks_reached.append(milestone)
			break_active = true
			paused = true
			_create_break_scene(milestone)
			pause_overlay.visible = true
			menu_heading.text = milestones[milestone]
			resume_button.text = "বিরতি শেষ — চালিয়ে যান"
			resume_button.visible = true
			shop_button.visible = false
			mission_button.visible = false
			daily_button.visible = false
			restart_button.text = "এখনই নতুন করে শুরু"
			pause_button.text = "▶"
			return

func _skin_color() -> Color:
	var colors := [Color(0.12, 0.25, 0.72), Color(0.12, 0.48, 0.28), Color(0.62, 0.16, 0.12), Color(0.12, 0.12, 0.16)]
	return colors[skin_index % colors.size()]

func _open_shop() -> void:
	if total_coins >= 100:
		total_coins -= 100
		skin_index = (skin_index + 1) % 4
		player_body.material_override.albedo_color = _skin_color()
		_save_progress()
		menu_heading.text = "নতুন পোশাক নেওয়া হয়েছে!"
	else:
		menu_heading.text = "নতুন পোশাকের দাম ১০০ কয়েন"
	resume_button.text = "ফিরে যান"
	resume_button.visible = true

func _show_missions() -> void:
	var distance_goal := clampf(distance_m / 1000.0, 0.0, 1.0)
	var coin_goal := clampf(float(coins) / 20.0, 0.0, 1.0)
	menu_heading.text = "মিশন: ১ কিমি %.0f%% | ২০ কয়েন %.0f%%" % [distance_goal * 100.0, coin_goal * 100.0]
	resume_button.text = "ফিরে যান"
	resume_button.visible = true

func _claim_daily_reward() -> void:
	var date := Time.get_date_dict_from_system()
	var today := int(date.year) * 10000 + int(date.month) * 100 + int(date.day)
	if daily_claim_day == today:
		menu_heading.text = "আজকের পুরস্কার নেওয়া হয়েছে"
	else:
		daily_claim_day = today
		total_coins += 50
		coins += 50
		_save_progress()
		menu_heading.text = "দৈনিক পুরস্কার: +৫০ কয়েন!"
	_update_hud()
	resume_button.text = "ফিরে যান"
	resume_button.visible = true

func _create_break_scene(milestone: int) -> void:
	if is_instance_valid(break_scene):
		break_scene.queue_free()
	break_scene = Node3D.new()
	break_scene.name = "DistanceBreakScene"
	break_scene.position = player.position + Vector3(0, 0, -5.5)
	world_root.add_child(break_scene)
	# A small Bangladesh roadside tea/food stall with a tin roof.
	_box(break_scene, Vector3(3.8, 0.18, 2.4), Vector3(0, 1.7, 0), Color(0.34, 0.40, 0.46))
	_box(break_scene, Vector3(3.3, 1.0, 0.22), Vector3(0, 0.72, -0.95), Color(0.48, 0.28, 0.12))
	for x in [-1.55, 1.55]:
		_box(break_scene, Vector3(0.12, 2.0, 0.12), Vector3(x, 0.8, -0.9), Color(0.30, 0.20, 0.10))
	_box(break_scene, Vector3(3.8, 0.12, 2.5), Vector3(0, 1.55, 0), Color(0.60, 0.16, 0.10))
	var food := MeshInstance3D.new()
	var dish := CylinderMesh.new()
	dish.top_radius = 0.38
	dish.bottom_radius = 0.32
	dish.height = 0.12
	food.mesh = dish
	food.position = Vector3(0, 1.28, -0.35)
	var food_mat := StandardMaterial3D.new()
	food_mat.albedo_color = Color(0.88, 0.72, 0.36) if milestone == 5000 else Color(0.78, 0.78, 0.68)
	food.material_override = food_mat
	break_scene.add_child(food)
	_box(break_scene, Vector3(1.1, 0.65, 0.8), Vector3(-2.1, 0.32, 0.8), Color(0.38, 0.24, 0.12))
	_box(break_scene, Vector3(1.1, 0.65, 0.8), Vector3(2.1, 0.32, 0.8), Color(0.38, 0.24, 0.12))

func _update_day_night(delta: float) -> void:
	day_clock = fmod(day_clock + delta * 0.012, TAU)
	var daylight := clampf(0.52 + 0.48 * sin(day_clock - PI * 0.5), 0.12, 1.0)
	sun_light.light_energy = 0.18 + daylight * 1.15
	sun_light.rotation_degrees.x = -12.0 - daylight * 55.0
	world_environment.environment.ambient_light_energy = 0.25 + daylight * 0.55
	world_environment.environment.ambient_light_color = Color(0.32, 0.39, 0.56).lerp(Color(0.72, 0.78, 0.82), daylight)

func _load_progress() -> void:
	var save := ConfigFile.new()
	if save.load("user://jibon_runner_save.cfg") == OK:
		best_score = int(save.get_value("progress", "best_score", 0))
		total_coins = int(save.get_value("progress", "total_coins", 0))
		skin_index = int(save.get_value("progress", "skin_index", 0))
		daily_claim_day = int(save.get_value("progress", "daily_claim_day", 0))

func _save_progress() -> void:
	var save := ConfigFile.new()
	save.set_value("progress", "best_score", best_score)
	save.set_value("progress", "total_coins", total_coins)
	save.set_value("progress", "skin_index", skin_index)
	save.set_value("progress", "daily_claim_day", daily_claim_day)
	save.save("user://jibon_runner_save.cfg")
