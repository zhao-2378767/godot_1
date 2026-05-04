extends CanvasLayer

signal upgrade_selected(upgrade_id: String)

@onready var health_label: Label = $Panel/VBoxContainer/HealthLabel
@onready var kills_label: Label = $Panel/VBoxContainer/KillsLabel
@onready var level_label: Label = $Panel/VBoxContainer/LevelLabel
@onready var exp_label: Label = $Panel/VBoxContainer/ExpLabel
@onready var stats_label: Label = $Panel/VBoxContainer/StatsLabel
@onready var help_label: Label = $Panel/VBoxContainer/HelpLabel
@onready var game_over_label: Label = $GameOverLabel
@onready var upgrade_panel: Panel = $UpgradePanel
@onready var upgrade_buttons := [
	$UpgradePanel/VBoxContainer/BulletButton,
	$UpgradePanel/VBoxContainer/AttackSpeedButton,
	$UpgradePanel/VBoxContainer/PierceButton,
	$UpgradePanel/VBoxContainer/SplitButton,
	$UpgradePanel/VBoxContainer/DamageButton
]

var upgrade_ids := ["bullet_count", "attack_speed", "pierce", "split", "damage"]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	upgrade_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	game_over_label.visible = false
	upgrade_panel.visible = false
	help_label.text = "WASD 移动｜自动攻击最近敌人｜击杀敌人获得经验"

	for i in range(upgrade_buttons.size()):
		upgrade_buttons[i].process_mode = Node.PROCESS_MODE_ALWAYS
		upgrade_buttons[i].pressed.connect(_on_upgrade_button_pressed.bind(i))

func set_health(current_health: int, max_health: int) -> void:
	health_label.text = "生命值：%d / %d" % [current_health, max_health]

func set_kills(kills: int) -> void:
	kills_label.text = "击杀数：%d" % kills

func set_level(level: int) -> void:
	level_label.text = "等级：%d" % level

func set_exp(current_exp: int, next_level_exp: int) -> void:
	exp_label.text = "经验：%d / %d" % [current_exp, next_level_exp]

func set_stats(stats_text: String) -> void:
	stats_label.text = stats_text

func show_upgrade_choices() -> void:
	upgrade_panel.visible = true

func hide_upgrade_choices() -> void:
	upgrade_panel.visible = false

func show_game_over() -> void:
	game_over_label.visible = true

func _on_upgrade_button_pressed(index: int) -> void:
	upgrade_selected.emit(upgrade_ids[index])
