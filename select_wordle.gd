extends Control

func _ready() -> void:
	Global.reset_wordle_selection()
	Global.load_from_storage()
	show_list_wordle_templates()

func show_list_wordle_templates():
	for i in range(len(Global.templates)):
		var template = Global.templates[i]
		var button_child : Button = Button.new()
		button_child.text = template.name + " #" + str(i)
		var iconImg : Image = Image.load_from_file(template.logopath)
		iconImg.resize(128, 128)
		var icon : ImageTexture = ImageTexture.create_from_image(iconImg)
		icon.set_image(iconImg)
		button_child.icon = icon
		button_child.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button_child.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		button_child.name = "button[" + str(i) + "]." + template.name
		button_child.pressed.connect(select_wordle(i))
		var margin_container: MarginContainer = MarginContainer.new()
		margin_container.add_theme_constant_override("margin_bottom", 16)
		margin_container.add_theme_constant_override("margin_top", 16)
		margin_container.add_theme_constant_override("margin_left", 16)
		margin_container.add_theme_constant_override("margin_right", 16)
		margin_container.add_child(button_child)
		$gc_area.add_child(margin_container)

func select_wordle(index: int):
	Global.selected_wordle = index
	return func(): get_tree().change_scene_to_file("res://gameplay.tscn")


func _on_btn_back_pressed() -> void:
	Global.reset_wordle_selection()
	get_tree().change_scene_to_file("res://main_menu.tscn")
