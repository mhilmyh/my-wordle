extends Control


func _on_btn_github_pressed() -> void:
	OS.shell_open("https://github.com/mhilmyh/my-wordle")

func _on_btn_exit_pressed() -> void:
	get_tree().quit()

func _on_btn_create_template_pressed() -> void:
	get_tree().change_scene_to_file("res://create_template_menu.tscn")

func _on_btn_select_wordle_pressed() -> void:
	get_tree().change_scene_to_file("res://select_wordle.tscn")

func _on_btn_clear_save_data_pressed() -> void:
	Global.clear_storage()
