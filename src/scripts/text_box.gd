extends MarginContainer

@onready var label = $MarginContainer/Label
@onready var timer = $LetterDisplayTimer
@onready var chat_display_timer = $ChatTimer

const MAX_WIDTH = 256
const MIN_WIDTH = 5

var text = ""
var letter_index = 0

var letter_time = 0.03
var space_time = 0.06
var punctuation_time = 0.2

signal finished_displaying()

func display_text(text_to_display: String):
	visible = true
	
	# 毎回参照を取らないとだめっぽい。
	label = $MarginContainer/Label
	timer = $LetterDisplayTimer
	text = text_to_display
	label.text = text_to_display
	
	print(text.length())
	
	# 文字数が超少なくて、resizeが必要ないと、awaitで止まってしまうのでその対策。
	if text.length() > MIN_WIDTH:
		await resized
	custom_minimum_size.x = min(size.x, MAX_WIDTH)
	
	# MAX_WIDTH超えたら、改行
	if size.x > MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await resized
		await resized
		custom_minimum_size.y = size.y
		
	label.text = ""
	# _display_letter()
	_display_chatter_letter()
	chat_display_timer.start(10.0)

func _display_chatter_letter():
	label.text += text[letter_index]
	
	letter_index += 1
	
	# 全部表示し終わったら、finishをemit
	if letter_index >= text.length():
		finished_displaying.emit()
		letter_index = 0
		return
	
	match text[letter_index]:
		"!", ".", ",", "?":
			timer.start(punctuation_time)
		" ":
			timer.start(space_time)
		_:
			timer.start(letter_time)

# ちょっと表示を送らせるためのtimer
func _display_letter():
	label.text += text[letter_index]
	
	letter_index += 1
	
	# 全部表示し終わったら、finishをemit
	if letter_index >= text.length():
		finished_displaying.emit()
		return
	
	match text[letter_index]:
		"!", ".", ",", "?":
			timer.start(punctuation_time)
		" ":
			timer.start(space_time)
		_:
			timer.start(letter_time)

var bubble_up_speed = 10
func _process(delta):
	position.y -= bubble_up_speed * delta
	


func _on_letter_display_timer_timeout():
	#_display_letter()
	_display_chatter_letter()


func _on_chat_timer_timeout():
	visible = false
	label = ""
	custom_minimum_size = Vector2(0, 0)
	queue_free()
