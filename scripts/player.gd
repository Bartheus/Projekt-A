extends CharacterBody2D

@export var speed := 220.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hp_fill: ColorRect = $HPBar/Fill

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

@export var attack_rate := 3.0        # ataki na sekundę (3 = co ~0.33s)
@export var attack_active_time := 0.08 # ile sekund hitbox jest aktywny
@export var max_hp := 100


@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D

var _attack_cd := 0.0
var _attack_timer := 0.0
var _is_attacking := false
var hp := 100
var _dead := false
var last_dir_index := 0
var _hp_bar_full_width := 44.0


func _ready() -> void:
	hp = max_hp
	_update_hp_bar()

	if attack_shape:
		attack_shape.disabled = true


func _physics_process(delta: float) -> void:
	# Ruch
	var move_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = move_dir * speed
	move_and_slide()

	var aim_dir := _get_mouse_dir()

	# cooldown attack
	if _attack_cd > 0.0:
		_attack_cd -= delta

	# timer hitboxa (może zostać, ale na razie nie musi)
	if _attack_timer > 0.0:
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			attack_shape.disabled = true

	# AUTO-ATTACK: trzymasz LMB
	if Input.is_action_pressed("attack") and _attack_cd <= 0.0 and not _is_attacking:
		_do_attack()
		return  # ważne: nie odpalaj walk/idle w tej klatce

	# Jeśli NIE atakujesz, normalne animacje myszka + walk/idle
	if not _is_attacking:
		_update_anim_16dir(aim_dir, move_dir.length() > 0.01)


func _get_mouse_dir() -> Vector2:
	var mouse_pos := get_global_mouse_position()
	var d := mouse_pos - global_position
	if d.length() < 1.0:
		return Vector2.ZERO
	return d.normalized()
	
func _update_anim_16dir(dir: Vector2, is_moving: bool) -> void:
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT

	var angle := atan2(-dir.y, dir.x)
	var idx := wrapi(int(round((angle / TAU) * 16.0)), 0, 16)
	last_dir_index = idx

	var prefix := "walk_" if is_moving else "idle_"
	var anim := _anim_name_from_index(idx, prefix)

	# fallback: jak nie masz jeszcze idle dla jakiegoś kierunku, użyj walk
	if not sprite.sprite_frames.has_animation(anim):
		prefix = "walk_"
		anim = _anim_name_from_index(idx, prefix)
		if not sprite.sprite_frames.has_animation(anim):
			return

	# graj zawsze właściwą animację (idle/walk), żeby obrót myszką działał
	if sprite.animation != anim:
		sprite.play(anim)



func _anim_name_from_index(i: int, prefix: String) -> String:
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


	
func _do_attack() -> void:
	_is_attacking = true
	_attack_cd = 1.0 / attack_rate

	var dir := _get_mouse_dir()
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT

	var angle := atan2(-dir.y, dir.x)
	var idx := wrapi(int(round((angle / TAU) * 16.0)), 0, 16)
	last_dir_index = idx

	var anim := _anim_name_from_index(idx, "attack_")

	# fallback jakby brakowało któregoś kierunku
	if not sprite.sprite_frames.has_animation(anim):
		anim = "attack_E"
		if not sprite.sprite_frames.has_animation(anim):
			_is_attacking = false
			return

	sprite.play(anim)

	# koniec ataku po zakończeniu animacji
	sprite.animation_finished.connect(func():
		_is_attacking = false
	, CONNECT_ONE_SHOT)
	
func _update_hp_bar() -> void:
	var ratio := float(hp) / float(max_hp)
	ratio = clamp(ratio, 0.0, 1.0)

	# zmieniamy tylko szerokość Fill
	hp_fill.size.x = _hp_bar_full_width * ratio
	
	
func take_damage(amount: int) -> void:
	if _dead:
		return

	hp -= amount
	_update_hp_bar()
	print("Player HP:", hp)

	if hp <= 0:
		_die()


		
		
func _die() -> void:
	if _dead:
		return
	_dead = true
	$HPBar.hide()


	# zablokuj ruch/atak
	set_physics_process(false)
	velocity = Vector2.ZERO
	if attack_shape:
		attack_shape.disabled = true

	# wybierz właściwą animację śmierci po ostatnim kierunku
	var death_anim := _anim_name_from_index(last_dir_index, "death_")

	if not sprite.sprite_frames.has_animation(death_anim):
		print("Brak animacji:", death_anim)
		sprite.stop()
		return

	# odpal śmierć (Loop OFF w SpriteFrames!)
	sprite.play(death_anim)

	# po zakończeniu - schowaj (albo queue_free)
	sprite.animation_finished.connect(func():
		hide()
		# queue_free()
	, CONNECT_ONE_SHOT)
