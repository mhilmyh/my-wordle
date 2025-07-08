extends Control

@onready var guessing_list: Array = []
@onready var audioStreamPlayer: AudioStreamPlayer = $sound_player
@onready var searchCandidateContainer: VBoxContainer = $vbox_search/bg_search_result/scroll_container_search/vbox_search_candidate
@onready var searchCandidatePanel: Panel = $vbox_search/bg_search_result
@onready var wordleData: Array = []
@onready var scoreWidget: Label = $score_margin/score

@onready var inputDebouncer = $input_debouncer
@onready var lastKnownInput = ""

@onready var noBgColor = Color(0.0, 0.0, 0.0)
@onready var correctBgColor = Color(0.2, 0.8, 0.2)
@onready var partialCorrectBgColor = Color(0.8, 0.8, 0.2)
@onready var wrongBgColor = Color(0.8, 0.2, 0.2)

# reset able
@onready var alreadyPicked = {}
@onready var randomCandidatePicked = -1
@onready var judgeContainer: GridContainer = $result_margin/scroll_container_result/grid_container

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
	searchCandidatePanel.hide()
	
	for i in searchCandidateContainer.get_children():
		searchCandidateContainer.remove_child(i)
		i.queue_free()
		
	for i in range(len(wordleData)):
		var wd = wordleData[i]
		var key = wd[0]
		
		var j = 0
		while j < len(Global.wordle_headers): 
			if Global.wordle_type[Global.wordle_headers[j]] == "str":
				key += " (" + wd[j] + ")"
				break
			j += 1
			
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
	alreadyPicked[current_index] = true
	
	searchCandidatePanel.hide()
	
	var correctGuess = 0
	
	for i in range(len(row)):
		var styleBox = StyleBoxFlat.new()
		var result = Global.compare_cell(i, randomCandidatePicked, current_index)
		if result == -1:
			styleBox.bg_color = noBgColor
		elif result == 1:
			styleBox.bg_color = correctBgColor
			correctGuess += 1
		elif result == 2:
			styleBox.bg_color = partialCorrectBgColor
		else:
			styleBox.bg_color = wrongBgColor
		
		var cell = row[i]
		if result == 3:
			cell += " <"
		elif result == 4:
			cell += " >"
			
		var gridItem = _generate_default_grid_items(cell)
		gridItem.add_theme_stylebox_override("panel", styleBox)
		judgeContainer.add_child(gridItem)
	
	# correct guess found
	if correctGuess == len(row):
		# TODO: show dialog saying "you win!"
		pass
	else:
		var currentGuessSoFar = (judgeContainer.get_child_count() / len(Global.wordle_headers))-1
		var totalAvailableGuess = len(wordleData)
		scoreWidget.text = "Score: " + str(100.0 * (totalAvailableGuess-currentGuessSoFar) / totalAvailableGuess)

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
	# TODO: show dialog saying "are you sure ?"
	for child in judgeContainer.get_children():
		judgeContainer.remove_child(child)
	_render_column_header()
	
	alreadyPicked = {}
	
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
	var hasResult = false
	
	for i in range(searchCandidateContainer.get_child_count()):
		var ch = searchCandidateContainer.get_child(i) 
		var btn = ch as Button
		if i in alreadyPicked:
			btn.hide()
		elif lastKnownInput in btn.text.to_lower():
			btn.show()
			hasResult = true
		else:
			btn.hide()
	if hasResult:
		searchCandidatePanel.show()
	else:
		searchCandidatePanel.hide()
	
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
	
