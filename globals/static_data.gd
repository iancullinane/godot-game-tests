extends Node

var item_data = {}
var data_file_path = "res://data/static_data.json"

func _ready():
	item_data = load_static_data(data_file_path)

func load_static_data(filePath: String):
	if FileAccess.file_exists(data_file_path):
		var dataFile = FileAccess.open(data_file_path, FileAccess.READ)
		var parsedResult = JSON.parse_string(dataFile.get_as_text())
		
		if parsedResult is Dictionary:
			return parsedResult
		else:
			print("error reading file")
	else:
		print("file does not exist")
