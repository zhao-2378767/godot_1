extends CharacterBody2D

@export var speed: float = 115.0
@export var max_health: int = 3
@export var touch_damage: int = 8
@export var damage_interval: float = 0.55

var current_health: int
var _damage_timer := 0.0

func _ready() -> void:
	add_to_group("enemies")
	current_health = max_health

func _physics_process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	var direction := global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()

	_damage_timer -= delta
	if global_position.distance_to(player.global_position) < 34.0 and _damage_timer <= 0.0:
		_damage_timer = damage_interval
		if player.has_method("take_damage"):
			player.take_damage(touch_damage)

func take_damage(amount: int) -> void:
	current_health -= amount
	if current_health <= 0:
		_die()

func _die() -> void:
	var main := get_tree().current_scene
	if main != null and main.has_method("enemy_killed"):
		main.enemy_killed()
	queue_free()
