extends Control

var credits = false

# Llamado cuando el nodo entra al árbol de escenas por primera vez
func _ready():
	$TextureRect.texture = preload("res://assets/Menu/-_Menu.png")

# Llamado en cada frame
func _process(delta):
	pass

# Llamado cuando se presiona el botón "Salir"
func _on_salir_pressed():
	get_tree().quit()

# Llamado cuando se presiona el botón "Jugar"
func _on_jugar_pressed():
	get_tree().change_scene_to_file("res://Mundo.tscn")

# Manejo de entrada de usuario
func _input(event):
	if event.is_action_released("ui_accept") or event.is_action_released("shoot"):
		if credits:
			# Oculta la página de créditos y muestra el menú principal
			credits = false
			$TextureRect.texture = preload("res://assets/Menu/-_Menu.png")
			$VBoxContainer.visible =true

# Llamado cuando se presiona el botón "Créditos"
func _on_creditos_pressed():
	if !credits:
		# Muestra la página de créditos
		$TextureRect.texture = preload("res://assets/Menu/-_Pagina creditos.png")
		credits = true
		$VBoxContainer.visible=false
