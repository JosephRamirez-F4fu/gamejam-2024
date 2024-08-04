extends TextureProgressBar


var maxvalor : int 
# Called when the node enters the scene tree for the first time.
func _ready():
	maxvalor = 100
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func disminuirVida(damage):
	value-=damage

func aumentarVida(cura):
	value+=cura

func get_vida():
	return value
