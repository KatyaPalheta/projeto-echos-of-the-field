extends Node2D
class_name DungeonGenerator

# World boundaries and room size
@export var world_size: Vector2i = Vector2i(4, 4)  # Defines the grid size for the dungeon
@export var number_of_rooms: int = 20  # Total number of rooms to generate

# The scene for the room instances
@onready var room_scene = preload("res://cenas/room.tscn")

# Root node for placing room instances
@onready var map_root = %MapRoot

# Variables for room management
var rooms: Array = []  # 2D grid of room data
var taken_positions: Array = []  # List of grid positions already occupied
var grid_size_x: int  # Horizontal grid size
var grid_size_y: int  # Vertical grid size

func _ready():
	# Ensure the number of rooms doesn't exceed available grid positions
	if number_of_rooms >= (world_size.x * 2) * (world_size.y * 2):
		number_of_rooms = int((world_size.x * 2) * (world_size.y * 2))
	
	grid_size_x = world_size.x
	grid_size_y = world_size.y

	# Generate rooms and setup the dungeon
	create_rooms()
	set_room_doors()
	draw_map()

func _input(event):
	# Reload the current scene when the "accept" input is pressed
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()

func create_rooms():
	# Initialize the room grid with null values
	rooms = []
	for i in range(grid_size_x * 2):
		var row = []
		for j in range(grid_size_y * 2):
			row.append(null)
		rooms.append(row)
	
	# Place the starting room at the grid center
	rooms[grid_size_x][grid_size_y] = {"grid_pos": Vector2i.ZERO, "type": 1}
	taken_positions.append(Vector2i.ZERO)

	# Generate additional rooms
	var random_compare_start = 0.2
	var random_compare_end = 0.01
	for i in range(number_of_rooms - 1):
		var random_compare = lerp(random_compare_start, random_compare_end, float(i) / (number_of_rooms - 1))
		var check_pos = new_position()
		
		# Ensure fewer neighbors for the new room based on probability
		if number_of_neighbors(check_pos) > 1 and randi() % 100 > random_compare * 100:
			var iterations = 0
			while number_of_neighbors(check_pos) > 1 and iterations < 100:
				check_pos = selective_new_position()
				iterations += 1
			if iterations >= 50:
				print("Error: Could not create with fewer neighbors than:", number_of_neighbors(check_pos))
		
		# Add the new room to the grid and mark its position
		rooms[check_pos.x + grid_size_x][check_pos.y + grid_size_y] = {"grid_pos": check_pos, "type": 0}
		taken_positions.append(check_pos)

func new_position() -> Vector2i:
	# Randomly select a new position adjacent to existing rooms
	var checking_pos = Vector2i.ZERO
	while true:
		var index = randi() % taken_positions.size()
		var base_pos = taken_positions[index]
		var up_down = randf() < 0.5  # Choose vertical or horizontal movement
		var positive = randf() < 0.5  # Choose direction (positive or negative)

		# Calculate the new position
		if up_down:
			checking_pos = base_pos + Vector2i(0, 1 if positive else -1)
		else:
			checking_pos = base_pos + Vector2i(1 if positive else -1, 0)

		# Ensure the position is within bounds and not already taken
		if not taken_positions.has(checking_pos) and checking_pos.x < grid_size_x and checking_pos.x > -grid_size_x and checking_pos.y < grid_size_y and checking_pos.y > -grid_size_y:
			break
	return checking_pos

func selective_new_position() -> Vector2i:
	# Similar to new_position but avoids positions with too many neighbors
	var checking_pos = Vector2i.ZERO
	var iterations = 0
	while true:
		iterations += 1
		var index = randi() % taken_positions.size()
		var base_pos = taken_positions[index]

		# Skip positions with too many neighbors
		if number_of_neighbors(base_pos) > 1 and iterations < 100:
			continue

		# Determine the new position
		var up_down = randf() < 0.5
		var positive = randf() < 0.5
		if up_down:
			checking_pos = base_pos + Vector2i(0, 1 if positive else -1)
		else:
			checking_pos = base_pos + Vector2i(1 if positive else -1, 0)

		# Validate the new position
		if not taken_positions.has(checking_pos) and checking_pos.x < grid_size_x and checking_pos.x > -grid_size_x and checking_pos.y < grid_size_y and checking_pos.y > -grid_size_y:
			break
	return checking_pos

func number_of_neighbors(pos: Vector2i) -> int:
	# Count the number of neighboring positions already occupied
	var count = 0
	for offset in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
		if taken_positions.has(pos + offset):
			count += 1
	return count

func set_room_doors():
	# Set door connections for each room based on neighboring rooms
	for x in range(grid_size_x * 2):
		for y in range(grid_size_y * 2):
			if rooms[x][y] == null:
				continue
			var room = rooms[x][y]
			room["door_top"] = (y - 1 >= 0) and rooms[x][y - 1] != null
			room["door_bot"] = (y + 1 < grid_size_y * 2) and rooms[x][y + 1] != null
			room["door_left"] = (x - 1 >= 0) and rooms[x - 1][y] != null
			room["door_right"] = (x + 1 < grid_size_x * 2) and rooms[x + 1][y] != null

func draw_map():
	# Instantiate and place room scenes based on the generated grid
	for x in range(grid_size_x * 2):
		for y in range(grid_size_y * 2):
			if rooms[x][y] == null:
				continue
			var room = rooms[x][y]
			var draw_pos = Vector2(room["grid_pos"].x, room["grid_pos"].y) * Vector2(16, 8)
			var instance = room_scene.instantiate()
			instance.position = draw_pos
			instance.type = room["type"]
			instance.door_top = room["door_top"]
			instance.door_bot = room["door_bot"]
			instance.door_left = room["door_left"]
			instance.door_right = room["door_right"]
			map_root.add_child(instance)
