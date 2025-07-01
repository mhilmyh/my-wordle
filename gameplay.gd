extends Control

@onready var guessing_list: Array = []

func _ready() -> void:
	draw_bg()
	draw_logo()
	toggle_music()
	
func toggle_music():
	pass

func draw_bg():
	pass
	
func draw_logo():
	pass

func _on_btn_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
	Global.reset_wordle_selection()

func _on_btn_reset_pressed() -> void:
	pass # Replace with function body.


func _on_btn_sound_pressed() -> void:
	toggle_music()
