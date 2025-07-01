extends Node

var templates: Array = []

var wordle_data: Array = []
var wordle_headers: Array = []
var wordle_type: Dictionary = {}

var selected_wordle: int = -1

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
	for i in range(len(templates)):
		if templates[i].name == name:
			templates.erase(i)
			return
			
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
			
func load_wordle_data_by_index(index: int):
	if index < 0 or index >= len(templates):
		return
	parse_csv(templates[index].datapath)
			
func parse_csv(file_path: String) -> Array:
	wordle_data = []
	wordle_headers = []
	wordle_type = {}
	
	if FileAccess.file_exists(file_path):
		var fa: FileAccess = FileAccess.open(file_path, FileAccess.READ)
		while not fa.eof_reached():
			var line = fa.get_line()
			var row = line.split(",")  # Split by commas
			if len(wordle_headers) == 0:
				for col in row:
					var column_configs: Array = col.split(":")
					if len(column_configs) > 0:
						wordle_headers.append(column_configs[0])
					if len(column_configs) > 1:
						wordle_type[column_configs[0]] = column_configs[1]
			else:
				wordle_data.append(row)
		fa.close()
	
	return wordle_data
