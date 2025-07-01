extends Control

@onready var le_name: LineEdit = $panel_form/le_name
@onready var le_bgpath: LineEdit = $panel_form/le_bgpath
@onready var le_logopath: LineEdit = $panel_form/le_logopath
@onready var le_musicpath: LineEdit = $panel_form/le_musicpath
@onready var le_datapath: LineEdit = $panel_form/le_datapath
@onready var label_warning: Label = $panel_form/label_warning

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
	
