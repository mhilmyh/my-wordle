extends Control

@onready var confirmation_dialog: AcceptDialog = $confirmation_dialog
@onready var temporary_buttons: Array[Button] = []
@onready var temporary_template_items: Array[MarginContainer] = []

func _ready() -> void:
	Global.reset_wordle_selection()
	Global.load_from_storage()
	show_list_wordle_templates()

func show_list_wordle_templates():
	for item in temporary_template_items:
		$gc_area.remove_child(item)
		item.queue_free()
	temporary_template_items.clear()
		
	for i in range(len(Global.templates)):
		var template = Global.templates[i]
		var button_child : Button = Button.new()
		button_child.text = template.name
		var iconImg : Image = Image.load_from_file(template.logopath)
		iconImg.resize(128, 128)
		var icon : ImageTexture = ImageTexture.create_from_image(iconImg)
		icon.set_image(iconImg)
		button_child.icon = icon
		button_child.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button_child.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		button_child.name = "button[" + str(i) + "]." + template.name
		button_child.pressed.connect(func(): _open_confirmation_dialog(i))
		var margin_container: MarginContainer = MarginContainer.new()
		margin_container.add_theme_constant_override("margin_bottom", 56)
		margin_container.add_theme_constant_override("margin_top", 56)
		margin_container.add_theme_constant_override("margin_left", 56)
		margin_container.add_theme_constant_override("margin_right", 56)
		margin_container.add_child(button_child)
		$gc_area.add_child(margin_container)
		temporary_template_items.append(margin_container)

func _open_confirmation_dialog(index: int) -> void:
	Global.selected_wordle = index
	confirmation_dialog.dialog_text = "You have click: " + str(Global.templates[index]['name'])
	
	for b in temporary_buttons:
		confirmation_dialog.remove_button(b)
		b.queue_free()
		
	temporary_buttons.clear()
	
	var newly_created_button = confirmation_dialog.add_button("Delete", true, "delete_template")
	temporary_buttons.append(newly_created_button)
	confirmation_dialog.show()

func _on_btn_back_pressed() -> void:
	Global.reset_wordle_selection()
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_confirmation_dialog_confirmed() -> void:
	get_tree().change_scene_to_file("res://gameplay.tscn")


func _on_confirmation_dialog_custom_action(action: StringName) -> void:
	if action == "delete_template":
		Global.delete_selected_template()
		Global.reset_wordle_selection()
		Global.load_from_storage()
		show_list_wordle_templates()
		confirmation_dialog.hide()
