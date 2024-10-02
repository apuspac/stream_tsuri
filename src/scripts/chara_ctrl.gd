extends Node2D
@export var chatter: PackedScene
var http_request

signal notice_charaname(name: String)
#var user_list: Array[String] = []
var user_list: Dictionary = {}
var chatter_position: Vector2 = Vector2(200, 200)
var chatter_name: String

# Called when the node enters the scene tree for the first time.
func _ready():
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
			instance_chara(msg_data["user"])
			pop_msg(msg_data["user"], msg_data["msg"])
	else:
		print("JSON parse error")
	

func _on_websockets_main_receive_emote(chat_msg: String):
	var json = JSON.new()
	var error = json.parse(chat_msg)
	
	if error == OK:
		var msg_data = json.data

		if  typeof(msg_data) == TYPE_DICTIONARY and msg_data.has("msg"):
			print(msg_data["msg"])
			instance_chara(msg_data["user"])
			pop_msg(msg_data["user"], msg_data["msg"])
		
		if typeof(msg_data) == TYPE_DICTIONARY and msg_data.has("emote_url"):
			print(msg_data["emote_url"])
			instance_chara(msg_data["user"])
			pop_emote(msg_data["user"], msg_data["emote_url"])
			
	else:
		print("chara_ctrl: JSON parse error")

func _on_websockets_main_receive_hydrate():
	print("NOMENOMENOMENOME")



# chatterでinstanceしてない人がいたら、in
func instance_chara(user_name: String):
	if not user_name in user_list:
		if user_name != "carry_nyan":
			var avatar = chatter.instantiate()
			chatter_position.x += 150
			avatar.position = chatter_position

			add_child(avatar)
			var label_node = avatar.get_node("Control/Name") 
			label_node.text = user_name
			
			# instanceしたら追加。
			user_list[user_name] = avatar

func pop_msg(chatter_name: String, msg: String):
	# 該当nameを持ったcharaを探して label_chatを更新
	if chatter_name in user_list:
		var chara = user_list[chatter_name]
		
		
		var label_chat = chara.get_node("Control/Chat")
		label_chat.text = msg
		
		
		var speech_bubble = chara.get_node("Control/TextBox")
		#speech_bubble.visible = true
		speech_bubble.display_text(msg)
		
		
		# ある程度時間が経ったら、消去するためのtimer開始。
		#var chat_timer = chara.get_node("ChatTimer")
		#chat_timer.start(10.0)


var popping_emote_name = ""
func pop_emote(emoter_name: String, emote_url: String):
	if emoter_name in user_list:
		# emoteの画像をhttp_request
		popping_emote_name = emoter_name
		var emote_request_error = http_request.request(emote_url)
		
		if emote_request_error != OK:
			push_error("An error occurred in the HTTP request.")

func pop_chara_emote(image: Image):
	if popping_emote_name in user_list:
		var chara = user_list[popping_emote_name]
		
		#var emote_texture = chara.get_node("Control/Emote")
		#var texture = ImageTexture.create_from_image(image)
		#emote_texture.texture = texture
		#emote_texture.visible = true
		
		var emote_box = chara.get_node("Control/EmoteBox")
		emote_box.display_emote(image)
		emote_box.visible = true
		
		## ある程度時間が経ったら、消去するためのtimer開始。
		var emote_timer = chara.get_node("EmoteTimer")
		emote_timer.start(10.0)

func _http_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Image couldn't be downloaded. Try a different image.")
	
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	

	if error != OK:
		push_error("Couldn't load the image.")

	pop_chara_emote(image)





	#var texture = ImageTexture.create_from_image(image)
#
#
	## Display the image in a TextureRect node.
	#var texture_rect = TextureRect.new()
	#add_child(texture_rect)
	#texture_rect.texture = texture
	#texture_rect.global_position = img_position 
	#img_position.x += 112



