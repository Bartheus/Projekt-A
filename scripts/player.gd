extends CharacterBody2D

@export var speed := 220.0
@onready var sprite: Sprite2D = $Sprite2D

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
	# 1. RUCH — WASD
	var move_dir := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)
	velocity = move_dir * speed
	move_and_slide()

	# 2. OBRÓT POSTACI — MYSZKA
	var aim_dir := _get_mouse_dir()
	_update_sprite_16dir(aim_dir)


func _update_sprite_16dir(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		_set_texture_by_index(last_dir_index)
		return

	if Input.is_action_pressed("move_down"):
		print("move_down pressed, dir=", dir)


	var angle := atan2(-dir.y, dir.x) # 0=E, +CCW, uwaga: -dir.y bo w 2D Y rośnie w dół
	var idx := int(round((angle / TAU) * 16.0)) % 16
	last_dir_index = idx
	_set_texture_by_index(idx)
	


func _set_texture_by_index(i: int) -> void:
	match i:
		0:  sprite.texture = tex_E
		1:  sprite.texture = tex_NEE
		2:  sprite.texture = tex_NE
		3:  sprite.texture = tex_NNE
		4:  sprite.texture = tex_N
		5:  sprite.texture = tex_NNW
		6:  sprite.texture = tex_NW
		7:  sprite.texture = tex_NWW
		8:  sprite.texture = tex_W
		9:  sprite.texture = tex_SWW
		10: sprite.texture = tex_SW
		11: sprite.texture = tex_SSW
		12: sprite.texture = tex_S
		13: sprite.texture = tex_SSE
		14: sprite.texture = tex_SE
		15: sprite.texture = tex_SEE
		
func _get_mouse_dir() -> Vector2:
	var mouse_pos := get_global_mouse_position()
	var d := mouse_pos - global_position
	if d.length() < 1.0:
		return Vector2.ZERO
	return d.normalized()
	
