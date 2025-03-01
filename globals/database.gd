extends Node

signal data_updated

var db = null  # Holds the SQLite database connection
const DB_PATH = "user://data.db"
const DB_ORIGINAL = "res://data.db"  # Original location in project

func _ready():
	_initialize_database()

func _initialize_database():
	# Copy database if it doesn't exist (first-time launch)
	if not FileAccess.file_exists(DB_PATH):
		print("Copying database from res:// to user://")
		DirAccess.copy_absolute(DB_ORIGINAL, DB_PATH)

	# Open the database
	db = SQLite.new()
	db.path = DB_PATH
	var err = db.open_db()
	if err:
		push_error("Failed to open SQLite database")
	else:
		print("Database initialized successfully")

# Wrappers to ensure signals are emitted
func select_players() -> Array:
	var select_sproc : String = "select * from players;"
	var success = db.query(select_sproc)
	if success:
		print("Inserted data successfully")
		#data_updated.emit()
	return db.query_result

# Wrappers to ensure signals are emitted
func add_row(table: String, data: Dictionary) -> bool:
	print("insert row")
	var success = db.insert_row(table, data)
	if success:
		print("Inserted data successfully")
		data_updated.emit()
	return success

func update_rows(table: String, condition: String, data: Dictionary) -> bool:
	var success = db.update_rows(table, condition, data)
	if success:
		print("Updated data successfully")
		data_updated.emit()
	return success

func delete_rows(table: String, condition: String) -> bool:
	var success = db.delete_rows(table, condition)
	if success:
		print("Deleted data successfully")
		data_updated.emit()
	return success
