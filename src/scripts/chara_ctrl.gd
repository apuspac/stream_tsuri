extends Node2D
@export var chatter: PackedScene
@onready var interaction = $interaction
@onready var water_body = $wave_move/water_body
@onready var wave_move = $wave_move
@onready var wave_timer = $WaveTimer



signal notice_charaname(name: String)
#var user_list: Array[String] = []
var user_list: Dictionary = {}
var chatter_position: Vector2 = Vector2(200, 200)
var chatter_name: String



var http_request := HTTPRequest.new()

var popping_emote_user: String = ""
var popping_emote_num = 1
var max_poppoing_emote_num = 1

var emote_name: String = ""


#var emote_gif: Array[SpriteFrames]
var popping_emote: Array[Emote.EmoteContainer]
var test_count = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	
	EmoteStore.list_files_in_dir("res://emotes/")
	print(EmoteStore.stored_emotes)
	

	
	# test
	# instance_chara("tester")
	#instance_chara("tester2")
	#instance_chara("tester3")



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

		if typeof(msg_data) == TYPE_DICTIONARY and msg_data.has("emote_url"):
			instance_chara(msg_data["user"])
			
			# get emote url and id
			var emotes = msg_data["emote_url"].split(",", true, 0)
			var emotes_id = msg_data["emote_id"].split(",", true, 0)
			
			pop_emote(msg_data["user"], emotes, emotes_id)
			
	else:
		print("chara_ctrl: JSON parse error")



func free_bigware():
	interaction.free_big_wave()
	wave_move.down_wave()
	



var setting_z_index = 1
# chatterでinstanceしてない人がいたら、in
func instance_chara(user_name: String):
	if not user_name in user_list:
		if user_name != "carry_nyan":
			var avatar = chatter.instantiate()
			avatar.position = chatter_position
			# avatarが被ったときにnameがずれるようにするためのindex
			avatar.z_index = setting_z_index

			add_child(avatar)
			var label_node = avatar.get_node("Control/Name")
			label_node.text = user_name

			
			# instanceしたら追加。
			user_list[user_name] = avatar
	
	if chatter_position.x > 1000:
		chatter_position.x -= 150
	elif chatter_position.x > 0:
		chatter_position.x += 150
	
	
	if setting_z_index < 10:
		setting_z_index += 1
	else:
		setting_z_index = 1

func pop_msg(_chatter: String, msg: String):
	# 該当nameを持ったcharaを探して label_chatを更新
	if _chatter in user_list:
		var chara = user_list[_chatter]
		
		# old 
		# 使ってないけど、test用に。
		var label_chat = chara.get_node("Control/Chat")
		label_chat.text = msg
		
		# var speech_bubble = chara.get_node("Control/TextBox")
		# speech_bubble.display_text(msg)
		
		var speech_bubble = chara.get_node("Control")
		speech_bubble.display_text(msg)



# 受け取ってhttpeリクエスト。
func pop_emote(emoter_name: String, emotes_url: Array[String], emotes_id: Array[String]):
	# 複数emoteをまとめて表示させるためcounter
	#popping_emote_num = 0
	#max_poppoing_emote_num = len(emotes_url)
	
	for i in len(emotes_url):
		# storeされてるか確認
		var emote_dic
		var emote_stored_flag = false
		for es in EmoteStore.stored_emotes:
			if es.name == emotes_id[i]:
				emote_stored_flag = true
				emote_dic = es
				
		if emote_stored_flag:
			# されてた。
			print("STORED")
			var img
			if emote_dic.format == "static":
				img = EmoteStore.load_image(emote_dic.name)
				popping_emote.append(Emote.AddStatic(img, emote_dic.format))
			else:
				img = EmoteStore.load_gif(emote_dic.name)
				popping_emote.append(Emote.AddAnimated(img, emote_dic.format))
		else:
			#されてない。
			print("REQUEST")
			# emoteの画像をhttp_request
			emote_name = emotes_id[i]
			var emote_request_error = http_request.request(emotes_url[i])
			if emote_request_error != OK:
				push_error("An error occurred in the HTTP request.")
			
			# request終わるまで待機。
			await http_request.request_completed
	#
	#for i in emotes:
		#pop_emote(msg_data["user"], i, )
	
	pop_chara_emote(emoter_name)
	
func pop_chara_emote(emote_user: String):

	if emote_user in user_list:
		var chara = user_list[emote_user]
		var emote_bubble = chara.get_node("Control")
		emote_bubble.display_emote(popping_emote)
		
		popping_emote = []

func _http_request_completed(result, _response_code, _headers, body):
	var mime_type = ""
	
	for header in _headers:
		if header.begins_with("Content-Type:"):
			mime_type = header.replace("Content-Type: ", "").strip_edges()
			break

	
	if mime_type == "image/png":
		if result != HTTPRequest.RESULT_SUCCESS:
			push_error("Image couldn't be downloaded. Try a different image.")
		
		var image = Image.new()
		var error = image.load_png_from_buffer(body)
		if error != OK:
			push_error("Couldn't load the image.")
			
		popping_emote.append(Emote.AddStatic(image, emote_name))
		EmoteStore.save_image(image, emote_name)
		
	
	elif mime_type == "image/gif":
		var sprite_frames: SpriteFrames = GifManager.sprite_frames_from_buffer(body)
		
		# 複数のemoteを一緒に表示させるためにいったん保存
		popping_emote.append(Emote.AddAnimated(sprite_frames, emote_name))
		EmoteStore.save_gif(body, emote_name)


func _unhandled_input(event):
	if event.is_action_pressed("ui_text_backspace"):
		pop_msg("tester", "aaahhh aaahhh")
	if event.is_action_pressed("ui_page_down"):
		#pop_emote("tester", "https://static-cdn.jtvnw.net/emoticons/v2/emotesv2_e8d5598a20eb4a3c8d7804b8531cc41c/static/light/4.0", "test_id")
		#pop_emote("tester", "https://cdn.betterttv.net/emote/5ba6d5ba6ee0c23989d52b10/3x")
		#pop_emote("tester", "http://localhost:8080/emote/")
		pass
			
	if event.is_action_pressed("ui_accept"):
		#pop_emote("tester", "https://static-cdn.jtvnw.net/emoticons/v2/emotesv2_e8d5598a20eb4a3c8d7804b8531cc41c/animated/light/4.0", "test_name")		
		pop_msg("tester", "a.")
	if event.is_action_pressed("ui_b"):
		var hydrate_msg = "self"
		_on_websockets_main_receive_hydrate(hydrate_msg)
	if event.is_action_pressed("ui_c"):
		img_tester()

var img_tester_count = 1
func img_tester():
	var img = EmoteStore.load_gif(str(img_tester_count))
	popping_emote.append(Emote.AddAnimated(img, emote_name))
	
	var chara = user_list["test"]
	var emote_bubble = chara.get_node("Control")
	emote_bubble.display_emote(popping_emote)


	#var texture = ImageTexture.create_from_image(image)
	
#
	## Display the image in a TextureRect node.
	#var texture_rect = TextureRect.new()
	#add_child(texture_rect)
	#texture_rect.texture = texture
	#texture_rect.global_position = img_position 
	#img_position.x += 112





func _on_websockets_main_receive_hydrate(hydrate_msg):
	print("NOMENOMENOMENOME")
	wave_move.up_wave()
	interaction.init_big_wave()
	wave_timer.start(30.0)



func _on_wave_timer_timeout():
	free_bigware()

