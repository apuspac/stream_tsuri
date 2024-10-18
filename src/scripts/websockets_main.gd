extends Node

# The URL we will connect to.
@export var websocket_url = "ws://localhost:3001/godot"

signal receive_chat(chat_msg: String)
signal receive_emote(emote_msg: String)
signal receive_hydrate(hydrate_msg: String)

# Our WebSocketClient instance.
var socket = WebSocketPeer.new()

func _ready():
	# Initiate connection to the given URL.
	var err = socket.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)
	else:
		# Wait for the socket to connect.
		await get_tree().create_timer(2).timeout

		# Send data.
		socket.send_text("Test packet")

func _process(_delta):
	# Call this in _process or _physics_process. Data transfer and state updates
	# will only happen when calling this function.
	socket.poll()

	# get_ready_state() tells you what state the socket is in.
	var state = socket.get_ready_state()

	# WebSocketPeer.STATE_OPEN means the socket is connected and ready
	# to send and receive data.
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var receive_msg = socket.get_packet().get_string_from_utf8()
			print("Got data from server: ", receive_msg)
			
			var json = JSON.new()
			var error = json.parse(receive_msg)
			
			if error == OK:
				var msg_data = json.data
		
				if  typeof(msg_data) == TYPE_DICTIONARY and msg_data.has("emote_url"):
					receive_emote.emit(receive_msg)
				elif  typeof(msg_data) == TYPE_DICTIONARY and msg_data.has("msg"):
					receive_chat.emit(receive_msg)
				elif  typeof(msg_data) == TYPE_DICTIONARY and msg_data.has("hydrate"):
					receive_hydrate.emit(receive_msg)
			
			# emoteのurlが含まれてるか。
			#if receive_msg.contains("https://static-cdn"):

	# websocketのClose処理
	# WebSocketPeer.STATE_CLOSING means the socket is closing.
	# It is important to keep polling for a clean close.
	elif state == WebSocketPeer.STATE_CLOSING:
		pass
	# WebSocketPeer.STATE_CLOSED means the connection has fully closed.
	# It is now safe to stop polling.
	elif state == WebSocketPeer.STATE_CLOSED:
		# The code will be -1 if the disconnection was not properly notified by the remote peer.
		var code = socket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		set_process(false) # Stop processing.



