extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not $fondo.playing:
		$fondo.play()




func _on_jugador_update_personaje(op):
	match op:
		0:
			$HUD/Indicador.frame = 0
		1:
			$HUD/Indicador.frame = 2
		2:
			$HUD/Indicador.frame = 1

