extends CharacterBody2D

@export var speed := 60.0
@export var patrol_distance := 180.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var _start_x := 0.0
var _dir := 1.0

func _ready() -> void:
	_start_x = global_position.x
	_play_walk()

func _physics_process(delta: float) -> void:
	# patrol
	if global_position.x > _start_x + patrol_distance:
		_dir = -1.0
	elif global_position.x < _start_x - patrol_distance:
		_dir = 1.0

	velocity = Vector2(_dir * speed, 0.0)
	move_and_slide()
	_play_walk()

func _play_walk() -> void:
	# Jeśli masz animację "walk"
	if anim.sprite_frames.has_animation("walk"):
		if anim.animation != "walk":
			anim.play("walk")
		return

	# Jeśli masz tylko kierunkowe
	if anim.sprite_frames.has_animation("walk_E") and anim.sprite_frames.has_animation("walk_W"):
		var name := "walk_E" if _dir > 0 else "walk_W"
		if anim.animation != name:
			anim.play(name)
