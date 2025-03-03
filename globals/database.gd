extends Node

signal data_updated

var db = null  # Holds the SQLite database connection
const DB_PATH = "user://data.db"
const DB_ORIGINAL = "res://data.db"  # Original location in project

func _ready():
	_initialize_database()

func _initialize_database():
	# Ensure the database is copied from res:// to user://
	if not FileAccess.file_exists(DB_PATH):
		print("Copying database from res:// to user://")

		# Open the original database in res://
		var res_db = FileAccess.open(DB_ORIGINAL, FileAccess.READ)
		if res_db == null:
			push_error("Failed to open database from res://")
			return  # Prevent further execution

		# Read the database into memory
		var db_data = res_db.get_buffer(res_db.get_length())
		res_db.close()

		# Create the new database in user://
		var user_db = FileAccess.open(DB_PATH, FileAccess.WRITE)
		if user_db == null:
			push_error("Failed to create database in user://")
			return  # Prevent further execution

		# Write the copied data to user://
		user_db.store_buffer(db_data)
		user_db.close()
		print("Database copied successfully to user://")
	else:
		print("Database already exists in user://, no need to copy.")

	# Confirm database file size
	var check_db = FileAccess.open(DB_PATH, FileAccess.READ)
	if check_db:
		print("Database size in user:// ", check_db.get_length(), "bytes")
		check_db.close()
	else:
		push_error("Database file does not exist in user:// after copy")

	# Open the database
	db = SQLite.new()
	db.path = DB_PATH
	var err = db.open_db()
	# Instead of relying on err, run a simple test query
	if err:
		push_error("SQLite reported error on open, checking usability...")

	var test_query_success = db.query("SELECT name FROM sqlite_master WHERE type='table' LIMIT 1;")
	if test_query_success:
		print("Database opened and is accessible.")
	else:
		push_error("Database opened, but test query failed!")

# Wrappers to ensure signals are emitted
func select_players() -> Array:
	var select_sproc : String = "select * from players;"
	var _success = db.query(select_sproc)
	return db.query_result

# Wrappers to ensure signals are emitted
func send_query(q: String) -> Array:
	var success = db.query(q)
	if success:
		data_updated.emit()
	return db.query_result

# Wrappers to ensure signals are emitted
func add_row(table: String, data: Dictionary) -> bool:
	var success = db.insert_row(table, data)
	if success:
		data_updated.emit()
	return success

func update_rows(table: String, condition: String, data: Dictionary) -> bool:
	var success = db.update_rows(table, condition, data)
	if success:
		data_updated.emit()
	return success

func delete_rows(table: String, condition: String) -> bool:
	var success = db.delete_rows(table, condition)
	if success:
		data_updated.emit()
	return success
