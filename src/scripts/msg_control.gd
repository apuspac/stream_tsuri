extends Control
@onready var chat_label = $Label

var http_request
var img_position: Vector2 = Vector2(0, 0)

func _ready():
	# Create an HTTP request node and connect its completion signal.
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)



func _on_websockets_main_receive_chat(chat_msg):
	var json = JSON.new()
	var error = json.parse(chat_msg)
	
	if error == OK:
		var msg_data = json.data
		
		if  typeof(msg_data) == TYPE_DICTIONARY and msg_data.has("msg"):
			print(msg_data["msg"])
			chat_label.text += msg_data["msg"] + "\n"
	else:
		print("msg_ctrl: JSON parse error")
	
	
	
func _on_websockets_main_receive_emote(chat_msg: String):
	# Perform the HTTP request. The URL below returns a PNG image as of writing.
	print(chat_msg)
	#var error = http_request.request(chat_msg)
	#if error != OK:
		#push_error("An error occurred in the HTTP request.")




# Called when the HTTP request is completed.
# get emote maybe 
func _http_request_completed(result, _response_code, _headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Image couldn't be downloaded. Try a different image.")

	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image.")

	var texture = ImageTexture.create_from_image(image)


	# Display the image in a TextureRect node.
	var texture_rect = TextureRect.new()
	add_child(texture_rect)
	texture_rect.texture = texture
	texture_rect.global_position = img_position 
	img_position.x += 112
