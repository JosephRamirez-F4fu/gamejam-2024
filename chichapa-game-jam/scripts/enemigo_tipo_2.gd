extends CharacterBody2D


var vida = 3
var speed = 80.0
const SPEED_PERSEGUIR = 200
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var persiguir: bool = false

func _ready():
	velocity.x = speed

func _physics_process(delta):
	detect()
	if !persiguir:
		$AnimationPlayer.play("move")
		if is_on_wall():
			if !$Sprite2D.flip_h:
				velocity.x = speed
			else:
				velocity.x = -speed
		if velocity.x < 0:
			$Sprite2D.flip_h = false
		elif velocity.x > 0:
			$Sprite2D.flip_h = true
	move_and_slide()

func detect():
	if $right.is_colliding():
		var obj = $right.get_collider()
		if obj.is_in_group("Jugador"):
			persiguir = true
			$AnimationPlayer.play("rotar")
			velocity.x = SPEED_PERSEGUIR
			$Sprite2D.flip_h = true
		else:
			persiguir = false
			$AnimationPlayer.play("move")
	
	if $left.is_colliding():
		var obj = $left.get_collider()
		if obj.is_in_group("Jugador"):
			persiguir = true
			$AnimationPlayer.play("rotar")
			velocity.x = -SPEED_PERSEGUIR
			$Sprite2D.flip_h = false
		else:
			persiguir = false
			$AnimationPlayer.play("move")


func _on_area_2d_body_entered(body):
	if body.is_in_group("personaje"):
		body.take_damage(15)
