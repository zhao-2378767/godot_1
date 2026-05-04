extends Area2D

@export var speed: float = 720.0
@export var damage: int = 1
@export var life_time: float = 1.15

var direction := Vector2.RIGHT
var pierce_left: int = 0
var split_count: int = 0
var can_split: bool = true
var _hit_enemy_ids := {}

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func setup(new_direction: Vector2, new_damage: int = 1, new_pierce: int = 0, new_split_count: int = 0, allow_split: bool = true) -> void:
	damage = new_damage
	pierce_left = new_pierce
	split_count = new_split_count
	can_split = allow_split
	if new_direction.length() > 0:
		direction = new_direction.normalized()
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	life_time -= delta
	_check_manual_hit()
	if life_time <= 0.0:
		queue_free()

func _check_manual_hit() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy) and global_position.distance_to(enemy.global_position) < 20.0:
			_hit_enemy(enemy)
			return

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies"):
		_hit_enemy(body)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		_hit_enemy(area)

func _hit_enemy(enemy: Node) -> void:
	if not is_instance_valid(enemy):
		return

	var enemy_id := enemy.get_instance_id()
	if _hit_enemy_ids.has(enemy_id):
		return
	_hit_enemy_ids[enemy_id] = true

	if enemy.has_method("take_damage"):
		enemy.take_damage(damage)

	if can_split and split_count > 0:
		_spawn_split_bullets()
		can_split = false

	if pierce_left > 0:
		pierce_left -= 1
		return

	queue_free()

func _spawn_split_bullets() -> void:
	var bullet_scene: PackedScene = preload("res://scenes/Bullet.tscn")
	var parent := get_tree().current_scene
	if parent == null:
		return

	for i in range(split_count):
		var split_bullet := bullet_scene.instantiate()
		parent.add_child(split_bullet)
		split_bullet.global_position = global_position

		var offset_index := i - (split_count - 1) / 2.0
		var angle_offset := deg_to_rad(32.0 * offset_index)
		var split_direction := direction.rotated(angle_offset)
		if split_count == 1:
			split_direction = direction.rotated(deg_to_rad(35.0))

		split_bullet.setup(split_direction, damage, max(pierce_left - 1, 0), 0, false)
