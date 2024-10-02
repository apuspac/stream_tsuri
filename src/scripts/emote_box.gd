extends MarginContainer

func display_emote(image: Image):
	var texture = ImageTexture.create_from_image(image)
	var emote_texture_rect = $MarginContainer/TextureRect
	emote_texture_rect.texture = texture
