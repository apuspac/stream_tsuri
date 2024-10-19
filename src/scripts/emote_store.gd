extends Node

class StoreEmote:
	var name: String
	var format: String


var stored_emotes: Array[StoreEmote]


func save_image(img: Image, name: String) -> void:
	var path = "res://emotes/" + name + ".png"
	img.save_png(path)
	stored_emotes.append(emote_store_constructor(name, "static"))
	
func save_gif(gif: PackedByteArray, name: String) -> void:
	var path = "res://emotes/" + name
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(gif)
	stored_emotes.append(emote_store_constructor(name, "animated"))
	
func load_image(name: String) -> Image:
	# return Image.load_from_file(stored_emotes[name])
	var path = "res://emotes/" + name + ".png"
	return Image.load_from_file(path)

func load_gif(name: String) -> SpriteFrames:
	var path = "res://emotes/" + name
	var file = FileAccess.open(path, FileAccess.READ)
	var gif = file.get_file_as_bytes(path)
	
	return (GifManager.sprite_frames_from_buffer(gif))

func emote_store_constructor(name: String, format: String) -> StoreEmote:
	var es = StoreEmote.new()
	es.name = name
	es.format = format
	return es


func list_files_in_dir(path: String) -> void:
	var dir = DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("emote_dir: " + file_name)
			
			#importぬかす
			elif file_name.contains("import") == false:
				print("Found files: " + file_name)
				
				# png
				if file_name.contains("png") == true:
					stored_emotes.append(emote_store_constructor(file_name.get_basename(), "static"))
				# animated
				else:
					stored_emotes.append(emote_store_constructor(file_name, "animated"))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
