extends CharacterBody2D

signal health_changed(current_health: int, max_health: int)
signal died
signal stats_changed(stats_text: String)

@export var speed: float = 260.0
@export var max_health: int = 100
@export var base_attack_interval: float = 0.45
@export var attack_range: float = 520.0

var current_health: int
var _attack_timer := 0.0
var bullet_scene: PackedScene = preload("res://scenes/Bullet.tscn")

var bullet_count: int = 1
var attack_speed_level: int = 0
var pierce_level: int = 0
var split_level: int = 0
var damage_level: int = 0

func _ready() -> void:
	add_to_group("player")
	current_health = max_health
	health_changed.emit(current_health, max_health)
	_emit_stats()

func _physics_process(delta: float) -> void:
	_handle_movement()
	_handle_auto_attack(delta)

func _handle_movement() -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector * speed
	move_and_slide()

func _handle_auto_attack(delta: float) -> void:
	_attack_timer -= delta
	if _attack_timer > 0.0:
		return

	var target := _find_nearest_enemy()
	if target == null:
		return

	_attack_timer = _get_attack_interval()
	_shoot_at(target.global_position)

func _shoot_at(target_position: Vector2) -> void:
	var base_direction := target_position - global_position
	if base_direction.length() <= 0.0:
		base_direction = Vector2.RIGHT

	var spread_degrees := 10.0
	for i in range(bullet_count):
		var bullet := bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position

		var offset_index := i - (bullet_count - 1) / 2.0
		var direction := base_direction.normalized().rotated(deg_to_rad(spread_degrees * offset_index))
		bullet.setup(direction, _get_damage(), pierce_level, split_level)

func _find_nearest_enemy() -> Node2D:
	var nearest: Node2D = null
	var nearest_distance := attack_range
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		var distance := global_position.distance_to(enemy.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = enemy
	return nearest

func take_damage(amount: int) -> void:
	current_health = max(current_health - amount, 0)
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		died.emit()

func apply_upgrade(upgrade_id: String) -> void:
	match upgrade_id:
		"bullet_count":
			bullet_count += 1
		"attack_speed":
			attack_speed_level += 1
		"pierce":
			pierce_level += 1
		"split":
			split_level += 1
		"damage":
			damage_level += 1
	_emit_stats()

func _get_attack_interval() -> float:
	return max(base_attack_interval - attack_speed_level * 0.045, 0.08)

func _get_damage() -> int:
	return 1 + damage_level

func _emit_stats() -> void:
	var attack_per_second := 1.0 / _get_attack_interval()
	var stats_text := "子弹：%d｜攻速：%.1f/秒｜穿透：%d｜分裂：%d｜攻击力：%d" % [
		bullet_count,
		attack_per_second,
		pierce_level,
		split_level,
		_get_damage()
	]
	stats_changed.emit(stats_text)
