extends Control

@onready var guessing_list: Array = []
@onready var audioStreamPlayer: AudioStreamPlayer = $sound_player
@onready var searchCandidateContainer: VBoxContainer = $vbox_search/scroll_container_search/vbox_search_candidate
@onready var wordleData: Array = []
@onready var randomCandidatePicked = -1
@onready var judgeContainer: GridContainer = $scroll_container_result/grid_container

@onready var inputDebouncer = $input_debouncer
@onready var lastKnownInput = ""

func _ready() -> void:
	inputDebouncer.connect("timeout", _filter_loaded_candidates)
	inputDebouncer.one_shot = true
	
	wordleData = Global.load_wordle_data_by_index(Global.selected_wordle)
	
	_draw_bg()
	_draw_logo()
	
	var musicpath = str(Global.templates[Global.selected_wordle]['musicpath'])
	if musicpath.to_lower().ends_with(".wav"):
		var audioStream = AudioStreamWAV.load_from_file(musicpath)
		audioStreamPlayer.stream = audioStream
	elif musicpath.to_lower().ends_with(".mp3"):
		var audioStream = AudioStreamMP3.load_from_file(musicpath)
		audioStreamPlayer.stream = audioStream
		
	_toggle_music()
	_load_search_candidates()
	_pick_random_candidate()
	_render_column_header()
	
func _toggle_music():
	if audioStreamPlayer != null:
		audioStreamPlayer.playing = not audioStreamPlayer.playing
		
func _draw_bg():
	var bgImg : Image = Image.load_from_file(Global.templates[Global.selected_wordle]['bgpath'])
	var img : ImageTexture = ImageTexture.create_from_image(bgImg)
	img.set_image(bgImg)
	var style_box = StyleBoxTexture.new()
	style_box.texture = img	
	$panel_bg.add_theme_stylebox_override("panel", style_box)
	
func _draw_logo():
	var logoImg : Image = Image.load_from_file(Global.templates[Global.selected_wordle]['logopath'])
	var img : ImageTexture = ImageTexture.create_from_image(logoImg)
	img.set_image(logoImg)
	var style_box = StyleBoxTexture.new()
	style_box.texture = img	
	$panel_logo.add_theme_stylebox_override("panel", style_box)
	
func _load_search_candidates():
	for i in searchCandidateContainer.get_children():
		searchCandidateContainer.remove_child(i)
		i.queue_free()
		
	for i in range(len(wordleData)):
		var wd = wordleData[i]
		var key = wd[0]
		if Global.wordle_type[Global.wordle_headers[1]] == "str":
			key += " (" + wd[1] + ")"
			
		var btn = Button.new()
		btn.name = "searchButton["+str(i)+"]"
		btn.text = key
		btn.connect("pressed", func(): _guess_candidate_click(i))
		btn.hide()
		
		searchCandidateContainer.add_child(btn)
		
func _guess_candidate_click(current_index: int):
	for i in searchCandidateContainer.get_children():
		var btn = i as Button
		if btn.visible:
			btn.hide()
	
	var row = wordleData[current_index]
	for cell in row:
		var gridItem = _generate_default_grid_items(cell)
		# TODO: dont forget to colorize the column to green (exact match) / yellow (partial) / red (wrong)
		#gridItem.add_theme_stylebox_override()
		judgeContainer.add_child(gridItem)
		

func _render_column_header():
	judgeContainer.columns = len(Global.wordle_headers)
	for i in range(len(Global.wordle_headers)):
		var header = str(Global.wordle_headers[i])
		judgeContainer.add_child(_generate_default_grid_items(header))

func _pick_random_candidate():
	randomCandidatePicked = randi_range(0, len(wordleData))

func _on_btn_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
	Global.reset_wordle_selection()

func _on_btn_reset_pressed() -> void:
	_pick_random_candidate()

func _on_btn_sound_pressed() -> void:
	_toggle_music()

func _on_sound_player_finished() -> void:
	_toggle_music()

func _on_search_input_text_changed(new_text: String) -> void:
	if lastKnownInput != new_text:
		lastKnownInput = new_text
		inputDebouncer.start(0.5)
	
func _filter_loaded_candidates() -> void:
	for i in searchCandidateContainer.get_children():
		var btn = i as Button
		if lastKnownInput in btn.text.to_lower():
			btn.show()
		else:
			btn.hide()
	
func _generate_default_grid_items(labelText: String) -> PanelContainer:
	var label = Label.new()
	label.text = labelText
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var marginContainer = MarginContainer.new()
	marginContainer.add_theme_constant_override("margin_bottom", 8)
	marginContainer.add_theme_constant_override("margin_top", 8)
	marginContainer.add_theme_constant_override("margin_right", 8)
	marginContainer.add_theme_constant_override("margin_left", 8)
	marginContainer.add_child(label)
	var container = PanelContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	container.add_child(marginContainer)
	return container
	
