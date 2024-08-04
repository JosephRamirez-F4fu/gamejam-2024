extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


enum Modo {
	FLECHERO,
	MAGO,
	TANQUE,
}

signal update_personaje

@onready var animated_sprite = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var cooldown = $cooldown
@onready var cooldown_cambio_personaje = $cooldown_cambio_personaje
@onready var change = $transformacion
 
var flecha = preload("res://proyectil.tscn")

var current_mode := Modo.FLECHERO

var modos := {
	Modo.TANQUE: {
		"jump": "tanque_jump",
		"walk": "tanque_walk",
		"habilidad": "tanque_habilidad",
		"sprite": preload("res://assets/jugador/tanque/tanque.png")
	},
	Modo.MAGO: {
		"jump": "mago_jump",
		"walk": "mago_walk",
		"habilidad": "mago_habilidad",
		"sprite": preload("res://assets/jugador/curador/curador.png")
	},
	Modo.FLECHERO: {
		"jump": "flechero_jump",
		"walk": "flechero_walk",
		"habilidad": "flechero_habilidad",
		"sprite": preload("res://assets/jugador/flechero/arquero.png")
	}
}

func _ready():
	cambiar_modo(0)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		play_jump_animation()

	var direction = Input.get_axis("ui_left", "ui_right")

	if Input.is_action_pressed("shoot"):
		usar_habilidad()

	if Input.is_action_just_pressed("ui_left"):
		play_walk_animation()
		sprite.flip_h = true

	elif Input.is_action_just_pressed("ui_right"):
		play_walk_animation()
		sprite.flip_h = false

	if Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right"):
		stop_walk_animation()

	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func play_walk_animation():
	var modo_actual = modos[current_mode]
	animated_sprite.play(modo_actual["walk"])

func stop_walk_animation():
	var modo_actual = modos[current_mode]
	animated_sprite.play_backwards(modo_actual["walk"])

func play_jump_animation():
	var modo_actual = modos[current_mode]
	animated_sprite.play(modo_actual["jump"])

func play_habilidad_animation():
	var modo_actual = modos[current_mode]
	animated_sprite.play(modo_actual["habilidad"])
	
func cambiar_modo(op):
	if cooldown_cambio_personaje.is_stopped():
		cooldown_cambio_personaje.start()
		current_mode = op
		$transformacion/AnimationPlayer.play("change")
		match op:
			0:
				collision.scale.y = 1.5
				sprite.hframes = 9
				sprite.offset.y = -330
			1:
				collision.scale.y = 1
				sprite.hframes = 8
				sprite.offset.y = -420
			2:
				collision.scale.y = 1.8
				sprite.hframes = 8
				sprite.offset.y = -300

		actualizar_modo(op)

func actualizar_modo(op):
	var modo_actual = modos[current_mode]
	sprite.texture = modo_actual["sprite"]
	_on_tiempo_escudo_timeout()
	_on_tiempo_aura_timeout()
	$CambioPersonaje.play()
	update_personaje.emit(op)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			cambiar_modo(0)
		elif event.keycode == KEY_2:
			cambiar_modo(1)
		elif event.keycode == KEY_3:
			cambiar_modo(2)

func usar_habilidad():
	var modo_actual = modos[current_mode]
	if cooldown.is_stopped():
		cooldown.start()
		match current_mode:
			Modo.TANQUE:
				habilidad_tanque()
			Modo.MAGO:
				habilidad_mago()
			Modo.FLECHERO:
				play_habilidad_animation()
				habilidad_flechero()
				

func habilidad_tanque():
	if $escudo/TiempoEscudo.is_stopped():
		$escudo/TiempoEscudo.start()
		$escudo.visible = true
		$escudo/AnimationEscudo.play("proteger")

func habilidad_mago():
	if $aura/TiempoAura.is_stopped():
		$aura/TiempoAura.start()
		$aura.visible = true
		$aura/AnimationAura.play("aura")
		$aura/AudioStreamPlayer.play()
		get_tree().get_nodes_in_group("barra_vida_player")[0].aumentarVida(20)

func habilidad_flechero():
	var new_flecha = flecha.instantiate()
	if sprite.flip_h:
		new_flecha.direccion = -1
	else:
		new_flecha.direccion = 1
	new_flecha.position = Vector2(position.x, position.y)
	get_tree().current_scene.add_child(new_flecha)
	$ataque_flecha.play()

func _on_cooldown_timeout():
	cooldown.stop()


func _on_cooldown_cambio_personaje_timeout():
	cooldown_cambio_personaje.stop() # Replace with function body.

func _on_tiempo_escudo_timeout():
	$escudo/TiempoEscudo.stop() # Replace with function body.
	$escudo/AnimationEscudo.play_backwards("proteger")
	$escudo.visible = false

func _on_tiempo_aura_timeout():
	$aura/TiempoAura.stop()
	$aura.visible = false
	$aura/AudioStreamPlayer.stop()


func take_damage(amount):
	get_tree().get_nodes_in_group("barra_vida_player")[0].disminuirVida(amount)
	if get_tree().get_nodes_in_group("barra_vida_player")[0].get_vida() <= 0:
		die()

func die():
	set_physics_process(false)
	#$AnimationPlayer.play("morir")
	#await ($AnimationPlayer.animation_finished)
	_restart_scene()

func _restart_scene() -> void:
	get_tree().reload_current_scene()

func _on_area_2d_body_entered(body):
	if body.is_in_group("enemigo") and  $escudo/TiempoEscudo.is_stopped():
		take_damage(30)
