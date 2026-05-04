extends Node2D

@export var enemy_scene: PackedScene = preload("res://scenes/Enemy.tscn")
@export var spawn_interval: float = 1.0
@export var spawn_distance: float = 720.0
@export var exp_per_enemy: int = 1
@export var first_level_exp: int = 5
@export var level_exp_growth: int = 3

@onready var player = $Player
@onready var ui = $UI

var kills := 0
var level := 1
var current_exp := 0
var next_level_exp := 5
var _spawn_timer := 0.0
var _game_over := false

func _ready() -> void:
	randomize()
	next_level_exp = first_level_exp
	player.health_changed.connect(ui.set_health)
	player.died.connect(_on_player_died)
	player.stats_changed.connect(ui.set_stats)
	ui.upgrade_selected.connect(_on_upgrade_selected)
	ui.set_kills(kills)
	ui.set_level(level)
	ui.set_exp(current_exp, next_level_exp)

func _process(delta: float) -> void:
	if _game_over:
		return

	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = spawn_interval
		_spawn_enemy()

func _spawn_enemy() -> void:
	var enemy := enemy_scene.instantiate()
	add_child(enemy)
	var angle := randf() * TAU
	enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * spawn_distance

func enemy_killed() -> void:
	kills += 1
	ui.set_kills(kills)
	_add_exp(exp_per_enemy)

func _add_exp(amount: int) -> void:
	current_exp += amount
	while current_exp >= next_level_exp:
		current_exp -= next_level_exp
		_level_up()
	ui.set_exp(current_exp, next_level_exp)

func _level_up() -> void:
	level += 1
	next_level_exp += level_exp_growth
	ui.set_level(level)
	ui.set_exp(current_exp, next_level_exp)
	ui.show_upgrade_choices()
	get_tree().paused = true

func _on_upgrade_selected(upgrade_id: String) -> void:
	player.apply_upgrade(upgrade_id)
	ui.hide_upgrade_choices()
	get_tree().paused = false

func _on_player_died() -> void:
	_game_over = true
	ui.show_game_over()
	get_tree().paused = true
