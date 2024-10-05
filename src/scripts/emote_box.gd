extends MarginContainer

@onready var emote_display_timer = $EmoteTimer


#func _ready():
	#var sprite = get_node("MarginContainer/AnimatedSprite2D")
	#sprite.sprite_frames = GifManager.sprite_frames_from_file("res://assets/my/SUBtember.gif")
	#sprite.play()
	#print(sprite.sprite_frames)

func display_emote(image: Image):
	visible = true
	var texture = ImageTexture.create_from_image(image)
	var emote_texture_rect = $MarginContainer/TextureRect
	emote_texture_rect.texture = texture
	
	emote_display_timer.start(10.0)


func display_emote_GIF(image: SpriteFrames):
	visible = true
	var sprite = get_node("MarginContainer/AnimatedSprite2D")
		
	print(image)
	sprite.sprite_frames = image
	sprite.play()

	
	emote_display_timer.start(10.0)

# 上に登っていく～。
var bubble_up_speed = 10
func _process(delta):
	position.y -= bubble_up_speed * delta


func _on_emote_timer_timeout():
	fade_out()
	

var fade_duration = 1.0
func fade_out():
	var tween = get_tree().create_tween()
	tween.tween_property($MarginContainer/TextureRect, "modulate:a", 0, fade_duration)
	tween.play()
	await tween.finished
	tween.kill()
	queue_free()
