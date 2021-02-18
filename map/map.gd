extends TileMap
class_name GWJ30_Map


const DEBUG := false
const CELL_SIZE := 16

const CANDLES := 5

const WALL_ID := 0
const FLOOR_ID := 1
const DOOR_ID := 2

const TILE_TO_ACTION_MAP := {
	WALL_ID: GWJ30_TileAction_Wall,
	FLOOR_ID: GWJ30_TileAction_Floor,
	DOOR_ID: GWJ30_TileAction_Puzzle_Door,

	3: GWJ30_TileAction_Wall,
	4: GWJ30_TileAction_Wall,
	5: GWJ30_TileAction_Wall,
	6: GWJ30_TileAction_Wall,
	7: GWJ30_TileAction_Wall,
	8: GWJ30_TileAction_Wall,
	9: GWJ30_TileAction_Wall,
	10: GWJ30_TileAction_Wall,
	11: GWJ30_TileAction_Wall,

	12: GWJ30_TileAction_Chest,
	13: GWJ30_TileAction_Wall,
	14: GWJ30_TileAction_Table,
}

var actions := {}
var cells := {}
var astar := AStar.new()
var nav_points := PoolVector2Array()


func _ready() -> void:
	cell_size = Vector2(CELL_SIZE, CELL_SIZE)
	tile_set = preload("res://tiles/tileset.tres")
	scale = Vector2.ONE / CELL_SIZE

	var floor_tiles := []
	var inventories := []
	var free_inventory_slots := 0
	var puzzles := []

	for child in get_children():
		var room: GWJ30_Room = child
		var room_aabb = room.get_used_rect()
		for x in room_aabb.size.x:
			for y in room_aabb.size.y:
				var pos: Vector2 = Vector2(x, y) + room_aabb.position
				var cell := room.get_cellv(pos)
				assert(cell != -1, "Cell is invalid!")
				var map_pos := pos + room.position
				# Vector2i pls
				var key := PoolIntArray([map_pos.x, map_pos.y])
				# TODO find a better way to ensure openings without punching holes in walls
				if key in cells and cells[key] == 1 and cell == 0:
					pass
				#if key in cells and not (cells[key] == 1 and cell == 0):
				elif key in cells and not (cells[key] == 0 and cell == 1):
					# Override floors with walls, otherwise just check and skip
					assert(cells[key] == cell, "Two different tiles share the same location! %d & %d" % [cells[key], cell])
				else:
					if cells.get(key, -1) == 1:
						floor_tiles.erase(key)
					cells[key] = cell
					actions[key] = TILE_TO_ACTION_MAP[cell].new()
					actions[key].position = map_pos
					actions[key].map = self
					if cell == 1: # Floor tile
						floor_tiles.append(key)
					set_cell(key[0], key[1], cell)
					if actions[key] is GWJ30_TileAction_Inventory:
						inventories.push_back(actions[key].items)
		room.queue_free()

	var wall_gaps := PoolVector2Array()

	# Close off any potential gaps
	for floor_pos in floor_tiles:
		var pos := Vector2(floor_pos[0], floor_pos[1])
		var key: PoolIntArray = floor_pos
		key[0] += 1
		if key in actions:
			key[0] -= 2
			if key in actions:
				key[0] += 1
				key[1] += 1
				if key in actions:
					key[1] -= 2
					if key in actions:
						# Chirp chirp
						nav_points.push_back(pos)
						var index: int = _nav_pos_to_index(pos)
						assert(index >= 0, "Index must be 0 or greater")
						astar.add_point(index, Vector3(pos.x, pos.y, 0))
						continue
		wall_gaps.push_back(pos)
		actions[floor_pos] = GWJ30_TileAction_Wall.new()
		actions[floor_pos].position = pos
		actions[floor_pos].map = self
		cells[floor_pos] = WALL_ID
		set_cell(floor_pos[0], floor_pos[1], WALL_ID)

	# Select any gap as an exit
	# If none are found, select any wall tile next to a floor tile
	if len(wall_gaps) > 0:
		var pos := wall_gaps[randi() % len(wall_gaps)]
		var key := PoolIntArray([pos.x, pos.y])
		actions[key] = GWJ30_TileAction_Puzzle_Door.new()
		actions[key].position = pos
		actions[key].map = self
		cells[key] = DOOR_ID
		set_cell(key[0], key[1], DOOR_ID)
		# Prepend this puzzle so the key may be hidden behind other puzzles
		puzzles.push_front(actions[key])
	else:
		assert(false, "TODO")

	# Initialize navigation
	for from in nav_points:
		var from_index := _nav_pos_to_index(from)
		for rel_to in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]:
			var to: Vector2 = from + rel_to
			var to_index := _nav_pos_to_index(to)
			if astar.has_point(to_index):
				astar.connect_points(from_index, to_index, false)

	# Add puzzle items
	# puzzle_inventories is emptied whenever one is used to prevent a "cyclic" puzzle which
	# cannot be solved
	var puzzle_inventories := inventories.duplicate()
	# Collect all necessary puzzle items
	var puzzle_items := []
	var puzzle_item_count := 0
	for pzl in puzzles:
		var items: Array = pzl.get_necessary_items()
		puzzle_items.push_back(items)
		puzzle_item_count += len(items)
	# Place items in inventories
	if puzzle_item_count > len(puzzle_inventories):
		assert(false, "TODO")
	else:
		# There are plenty of free inventories, place wherever
		for pzl_items in puzzle_items:
			var used_invs := []
			for it in pzl_items:
				# Keep trying, we must place the item
				# Also, this shouldn't get stuck indefinitely anyways
				while true:
					var inv: Array = puzzle_inventories[randi() % len(puzzle_inventories)]
					if _place_item_in_inv(inv, it):
						used_invs.push_back(inv)
						break
			for inv in used_invs:
				puzzle_inventories.erase(inv)

	# Add candles
	for i in CANDLES:
		# Try at most 100 times to prevent infinite loop
		for _k in 100:
			if _place_item_in_inv(inventories[randi() % len(inventories)], "Candle"):
				break

	# Fill empty tiles and add border with walls to prevent ugly background from being visible
	var map_aabb := get_used_rect()
	print(map_aabb)
	for x in range(map_aabb.position.x, map_aabb.end.x):
		for y in range(map_aabb.position.y, map_aabb.end.y):
			if get_cell(x, y) == -1:
				set_cell(x, y, WALL_ID)
	for x in range(map_aabb.position.x - 1, map_aabb.end.x + 1):
		set_cell(x, map_aabb.position.y - 1, WALL_ID)
		set_cell(x, map_aabb.position.y + map_aabb.size.y, WALL_ID)
	for y in range(map_aabb.position.y, map_aabb.end.y):
		set_cell(map_aabb.position.x - 1, y, WALL_ID)
		set_cell(map_aabb.position.x + map_aabb.size.x, y, WALL_ID)

	if DEBUG:
		for key in actions:
			var pos := Vector2(key[0], key[1])
			var lbl := Label.new()
			lbl.text = "%d,%d\n%s\n%d" % [key[0], key[1], actions[key].name, cells[key]]
			if pos in nav_points:
				lbl.text += str("     NAV")
			lbl.rect_position = pos * 16
			lbl.rect_scale = Vector2.ONE / 4.0
			add_child(lbl)


func do_action(player: GWJ30_Player, direction: Vector2) -> GWJ30_TileActionResult:
	var pos := player.position - position + direction
	var key := PoolIntArray([pos.x, pos.y])
	return actions[key].do(player)


func get_actions(player: GWJ30_Player) -> GWJ30_TileActionList:
	var acts := []
	for dir in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		var pos: Vector2 = player.position - position + dir
		var key := PoolIntArray([pos.x, pos.y])
		acts.push_back(actions.get(key, GWJ30_TileAction_None.new()))
	var list := GWJ30_TileActionList.new()
	list.left = acts[0]
	list.right = acts[1]
	list.up = acts[2]
	list.down = acts[3]
	return list



func get_point_path(from: Vector2, to: Vector2) -> PoolVector2Array:
	from -= position
	to -= position
	var path3d := astar.get_point_path(_nav_pos_to_index(from), _nav_pos_to_index(to))
	var path2d := PoolVector2Array()
	for p in path3d:
		path2d.push_back(Vector2(p.x, p.y))
	return path2d


func get_any_floor_point() -> Vector2:
	return nav_points[randi() % len(nav_points)]


func _nav_pos_to_index(position: Vector2) -> int:
	return ((int(position.x) + 0x7ff) << 12) | (int(position.y) + 0x7ff)


static func _place_item_in_inv(inventory: Array, item: String) -> bool:
	var empty_slots := PoolIntArray()
	for i in len(inventory):
		if inventory[i] == null:
			empty_slots.push_back(i)
	if len(empty_slots) == 0:
		return false
	inventory[empty_slots[randi() % len(empty_slots)]] = item
	return true

