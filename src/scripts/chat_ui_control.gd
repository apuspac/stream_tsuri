extends Control
@export var text_box: PackedScene
@export var emote_box: PackedScene


func display_text(msg: String) -> void:
	var textbox = text_box.instantiate()
	textbox.position.y -= 50
	add_child(textbox)
	textbox.display_text(msg)

func display_emote(image: Image) -> void:
	var emotebox = emote_box.instantiate()
	emotebox.position.y -= 250
	add_child(emotebox)
	emotebox.display_emote(image)


func display_emote_GIF(image: SpriteFrames) -> void:
	var emotebox = emote_box.instantiate()
	emotebox.position.y -= 250
	add_child(emotebox)
	emotebox.display_emote_GIF(image)
