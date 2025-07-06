extends Control

@onready var le_name: LineEdit = $panel_form/le_name
@onready var le_bgpath: LineEdit = $panel_form/le_bgpath
@onready var le_logopath: LineEdit = $panel_form/le_logopath
@onready var le_musicpath: LineEdit = $panel_form/le_musicpath
@onready var le_datapath: LineEdit = $panel_form/le_datapath
@onready var label_warning: Label = $panel_form/label_warning
@onready var file_dialog: FileDialog = $file_dialog
@onready var opening_file_for = ""

func _ready() -> void:
	label_warning.text = ""
	Global.load_from_storage()

func _on_btn_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_btn_save_pressed() -> void:
	label_warning.text = ""
	
	if le_name.text.length() == 0:
		label_warning.text = "name cannot be empty."
		return
	else:
		for template in Global.templates:
			if template['name'] == le_name.text:
				label_warning.text = "name already exist."
				return
		
	if le_bgpath.text.length() == 0:
		label_warning.text = "background cannot be empty."
		return
	
	if not FileAccess.file_exists(le_bgpath.text):
		label_warning.text = "background must be exist."
		return
	else:
		var bgcheck: Image = Image.new()
		var img = bgcheck.load_from_file(le_bgpath.text)
		if img == null or img.get_data_size() == 0:
			label_warning.text = "background image cannot be loaded."
			return
		
	if le_logopath.text.length() == 0:
		label_warning.text = "logo cannot be empty."
		return
	
	if not FileAccess.file_exists(le_logopath.text):
		label_warning.text = "logo must be exist."
		return
	else:
		var logocheck: Image = Image.new()
		var img = logocheck.load_from_file(le_logopath.text)
		if img == null or img.get_data_size() == 0:
			label_warning.text = "logo image cannot be loaded."
			return
	
	if le_musicpath.text.length() == 0:
		label_warning.text = "music cannot be empty."
		return
			
	if not FileAccess.file_exists(le_musicpath.text):
		label_warning.text = "music must be exist."
		return
	else:
		if le_musicpath.text.to_lower().ends_with(".wav"):
			var a: AudioStreamWAV = AudioStreamWAV.load_from_file(le_musicpath.text)
			if a == null or a.get_length() == 0:
				label_warning.text = "music cannot loaded (.wav)."
				return
		elif le_musicpath.text.to_lower().ends_with(".mp3"):
			var a: AudioStreamMP3 = AudioStreamMP3.load_from_file(le_musicpath.text)
			if a == null or a.get_length() == 0:
				label_warning.text = "music cannot loaded (.mp3)."
				return
		else:
			label_warning.text = "music format not supported."
			return
		
	if le_datapath.text.length() == 0:
		label_warning.text = "data path cannot be empty."
		return
	
	if not FileAccess.file_exists(le_datapath.text):
		label_warning.text = "data path must be exist."
		return
	else:
		if not le_datapath.text.to_lower().ends_with(".csv"):
			label_warning.text = "data format not supported (must be .csv)."
			return 
			
	Global.add_template(
		le_name.text,
		le_bgpath.text,
		le_logopath.text,
		le_musicpath.text,
		le_datapath.text,
	)
	
	label_warning.text = "Saved (" + le_name.text + ")"
	
	Global.save_to_storage()
	
func _on_file_dialog_dir_selected(dir: String) -> void:
	_set_value_from_file_dialog_to_line_edit(dir)

func _on_file_dialog_file_selected(path: String) -> void:
	_set_value_from_file_dialog_to_line_edit(path)

func _on_file_dialog_files_selected(paths: PackedStringArray) -> void:
	if len(paths) > 0:
		_set_value_from_file_dialog_to_line_edit(paths[0])
	
func _set_value_from_file_dialog_to_line_edit(value: String) -> void:
	if opening_file_for == "bg":
		le_bgpath.text = value
	elif opening_file_for == "logo":
		le_logopath.text = value
	elif opening_file_for == "music":
		le_musicpath.text = value
	elif opening_file_for == "data":
		le_datapath.text = value
	
	opening_file_for = ""

func _on_btn_bg_pressed() -> void:
	opening_file_for = "bg"
	file_dialog.show()

func _on_btn_logo_pressed() -> void:
	opening_file_for = "logo"
	file_dialog.show()

func _on_btn_music_pressed() -> void:
	opening_file_for = "music"
	file_dialog.show()

func _on_btn_data_pressed() -> void:
	opening_file_for = "data"
	file_dialog.show()
