extends MarginContainer

@onready var emote_display_timer = $EmoteTimer


func display_emote(image: Image):
	visible = true
	var texture = ImageTexture.create_from_image(image)
	var emote_texture_rect = $MarginContainer/TextureRect
	emote_texture_rect.texture = texture
	
	emote_display_timer.start(10.0)

var bubble_up_speed = 10
func _process(delta):
	position.y -= bubble_up_speed * delta


func _on_emote_timer_timeout():
	visible = false
	queue_free()
