extends Node

# これいつでもどこでもdialogさんだと思うので、別に呼び出す必要はもしかしてない...?

@onready var text_box_scene = preload("res://src/scene/text_box.tscn")

var dialog_lines: Array[String] = []
var current_line_index = 0
var chat_lines: String

var text_box
var text_box_position: Vector2

var is_dialog_active = false
var can_advance_line = false

func start_chat_dialog(position: Vector2, _lines: String):
	chat_lines = _lines
	text_box_position = position
	_show_chat_box()
	
func _show_chat_box():
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	get_tree().root.add_child(text_box)
	text_box.global_position = text_box_position
	text_box.display_text(chat_lines)
	can_advance_line = false

func start_dialog(position: Vector2, lines: Array[String]):
	if is_dialog_active:
		return
	
	dialog_lines = lines
	text_box_position = position
	_show_text_box()
	
	is_dialog_active = true
	
func _show_text_box():
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	get_tree().root.add_child(text_box)
	text_box.global_position = text_box_position
	text_box.display_text(dialog_lines[current_line_index])
	can_advance_line = false
	
func _on_text_box_finished_displaying():
	can_advance_line = true
	
func _unhandled_input(event):
	# print(can_advance_line, is_dialog_active, event.is_action_pressed("ui_text_backspace"))
	if(
		event.is_action_pressed("ui_text_backspace") &&
		is_dialog_active &&
		can_advance_line
	):
		text_box.queue_free()
		
		# 次の行を呼び出すためのindex
		current_line_index += 1
		
		# 配列内のdialogが終わったら終了
		if current_line_index >= dialog_lines.size():
			is_dialog_active = false
			current_line_index = 0
			return
		
		_show_text_box()

const test_text = "aaahhh aaahhh"

const lines: Array[String] = [
	"A.",
	"It looks like if the first one is short, it's going to be ERROR..",
	"It looks like it has to be a certain length to go.",
	"Ccccccccccccccccccccccccc?cccccccccccccccccccccccc?Ccccccccccccccccccccccccc?",
]
#
#func _unhandled_input(event):
	#if event.is_action_pressed("ui_text_backspace"):
		#DialogManager.start_dialog(global_position, lines)




