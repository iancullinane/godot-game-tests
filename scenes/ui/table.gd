extends Control

var players = [
	{"name": "Alice", "score": 100},
	{"name": "Bob", "score": 90},
	{"name": "Charlie", "score": 85}
]

var database : SQLite

func _ready():
	
	database = SQLite.new()
	database.path = "res://data.db"
	database.open_db()
	
	var selection = database.select_rows("players", "stat >= 0", ["*"])
	if selection.size() == 0:
		print(Errors.DATA_SELECT_FAILED)
	else:
		print(selection)
	
	var table_container = $Panel/VBoxContainer/VBoxContainer  # Path to the row container
	
	for player in selection:
		var row = HBoxContainer.new()  # Create a row
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # Make it stretch
		
		var name_label = Label.new()
		name_label.text = player["name"]
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # Stretch evenly
		
		var score_label = Label.new()
		score_label.text = str(player["stat"])
		score_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # Stretch evenly
		
		row.add_child(name_label)
		row.add_child(score_label)
		
		table_container.add_child(row)  # Add the row to the VBoxContainer
