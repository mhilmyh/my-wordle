extends Node

var templates: Array = []

var wordle_data: Array = []
var wordle_headers: Array = []
var wordle_type: Dictionary = {}
var selected_wordle: int = -1

var httpRequest = HTTPRequest.new()
var image_cached: Dictionary[String,ImageTexture] = {}

func reset_wordle_selection():
	selected_wordle = -1
	wordle_data = []
	wordle_headers = []
	wordle_type = {}

func add_template(
	name: String,
	bgpath: String,
	logopath: String,
	musicpath: String,
	datapath: String
):
	templates.append({
		'name': name,
		'bgpath': bgpath,
		'logopath': logopath,
		'musicpath': musicpath,
		'datapath': datapath,	
	})
	
func remove_template(name: String):
	var target_index = -1
	for i in range(len(templates)):
		if templates[i]['name'] == name:
			target_index = i
			break
	templates.remove_at(target_index)

func delete_selected_template():
	templates.remove_at(selected_wordle)
	save_to_storage()


func save_to_storage():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	# JSON provides a static method to serialized JSON string.
	var json_string = JSON.stringify({
		'templates': templates,
	})

	# Store the save dictionary as a new line in the save file.
	save_file.store_line(json_string)
	
func clear_storage():
	if not FileAccess.file_exists("user://savegame.save"):
		return
	var err = DirAccess.remove_absolute("user://savegame.save")
	if err == OK:
		return
	print("failed to clear storage")
	
	
func load_from_storage():
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object.
		var node_data = json.data
		
		if node_data != null and node_data.templates != null:
			templates = node_data.templates
		else:
			print("JSON Parse Invalid: Something wrong!")
			
func load_wordle_data_by_index(index: int) -> Array:
	if index < 0 or index >= len(templates):
		return []
	return parse_csv(templates[index].datapath)
			
func parse_csv(file_path: String) -> Array:
	wordle_data = []
	wordle_headers = []
	wordle_type = {}
	
	if FileAccess.file_exists(file_path):
		var fa: FileAccess = FileAccess.open(file_path, FileAccess.READ)
		while not fa.eof_reached():
			var line = fa.get_line()
			var row = line.split(";")  # Split by commas
			
			if len(row) == 0 or (len(row) == 1 and row[0] == ""):
				break
				
			if len(wordle_headers) == 0:
				for col in row:
					var column_configs: Array = col.split(":")
					if len(column_configs) > 0:
						wordle_headers.append(column_configs[0])
					if len(column_configs) > 1:
						wordle_type[column_configs[0]] = column_configs[1]
					if column_configs[0] not in wordle_type or not is_supported_wordle_type(wordle_type[column_configs[0]]):
						wordle_type[column_configs[0]] = "str"
			else:
				wordle_data.append(row)
				
		fa.close()
	
	return wordle_data
	
func is_supported_wordle_type(value: String) -> bool:
	if value == "":
		return false
		
	return value in ["str", "int", "enum", "img"]
	
# compare_cell: 
# 4 -> greater than
# 3 -> lower than
# 2 -> partial match
# 1 -> exact match
# 0 -> wrong
# -1 -> no need color
func compare_cell(column_idx: int, row_target_idx: int, row_guess_idx: int) -> int:
	var header = wordle_headers[column_idx]
	var headerType = wordle_type[header]
	if not is_supported_wordle_type(headerType):
		headerType = "str"
	
	var target_cell_data = wordle_data[row_target_idx][column_idx]
	var guess_cell_data = wordle_data[row_guess_idx][column_idx]
	
	if headerType == "img":
		return -1
	elif headerType == "str":
		return 1 if target_cell_data == guess_cell_data else 0
	elif headerType == "int":
		var target_cell_data_int = int(target_cell_data)
		var guess_cell_data_int = int(guess_cell_data)
		if guess_cell_data_int == target_cell_data_int:
			return 1
		elif guess_cell_data_int > target_cell_data_int:
			return 4
		elif guess_cell_data_int < target_cell_data_int:
			return 3
	elif headerType == "enum":
		var target_cell_data_arr = String(target_cell_data).split(",")
		var guess_cell_data_arr = String(guess_cell_data).split(",")

		var cnt = 0
		for g in guess_cell_data_arr:
			if g in target_cell_data:
				cnt += 1
		if len(target_cell_data_arr) == len(guess_cell_data_arr):
			if cnt == len(guess_cell_data_arr):
				return 1
			else:
				return 2
		else:
			if cnt == len(guess_cell_data_arr):
				return 2
			else:
				return 0
	return 0
	
func load_image_from_url(url: String) -> bool:
	httpRequest.connect("request_completed", func(result, response_code, headers, body): _on_request_completed(url, result, response_code, headers, body))
	var err = httpRequest.request(url)
	if err != OK:
		print("load_image_from_url: ", err)
		return false
	return true
	
func _on_request_completed(url, result, response_code, headers, body):
	var image = Image.new()
	var err = image.load_png_from_buffer(body)
	if err != OK:
		print("_on_request_completed: ", err)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	image_cached[url] = texture
	
	
		
