extends CharacterBody2D

@export var speed := 220.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# 16 tekstur idle (po 1 klatce na kierunek)
@export var tex_E: Texture2D
@export var tex_NEE: Texture2D
@export var tex_NE: Texture2D
@export var tex_NNE: Texture2D
@export var tex_N: Texture2D
@export var tex_NNW: Texture2D
@export var tex_NW: Texture2D
@export var tex_NWW: Texture2D
@export var tex_W: Texture2D
@export var tex_SWW: Texture2D
@export var tex_SW: Texture2D
@export var tex_SSW: Texture2D
@export var tex_S: Texture2D
@export var tex_SSE: Texture2D
@export var tex_SE: Texture2D
@export var tex_SEE: Texture2D

var last_dir_index := 0

func _physics_process(delta: float) -> void:
	var move_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = move_dir * speed
	move_and_slide()

	# kierunek patrzenia: myszka (Hades style)
	var aim_dir := _get_mouse_dir()
	_update_anim_16dir(aim_dir, move_dir.length() > 0.01)

func _get_mouse_dir() -> Vector2:
	var mouse_pos := get_global_mouse_position()
	var d := mouse_pos - global_position
	if d.length() < 1.0:
		return Vector2.ZERO
	return d.normalized()

func _update_anim_16dir(dir: Vector2, is_moving: bool) -> void:
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT # fallback

	var angle := atan2(-dir.y, dir.x)
	var idx := wrapi(int(round((angle / TAU) * 16.0)), 0, 16)
	last_dir_index = idx

	var anim := _anim_name_from_index(idx, is_moving)
	if sprite.animation != anim:
		sprite.play(anim)

func _anim_name_from_index(i: int, is_moving: bool) -> String:
	var prefix := "walk_"
	match i:
		0:  return prefix + "E"
		1:  return prefix + "NEE"
		2:  return prefix + "NE"
		3:  return prefix + "NNE"
		4:  return prefix + "N"
		5:  return prefix + "NNW"
		6:  return prefix + "NW"
		7:  return prefix + "NWW"
		8:  return prefix + "W"
		9:  return prefix + "SWW"
		10: return prefix + "SW"
		11: return prefix + "SSW"
		12: return prefix + "S"
		13: return prefix + "SSE"
		14: return prefix + "SE"
		15: return prefix + "SEE"
	return prefix + "E"
