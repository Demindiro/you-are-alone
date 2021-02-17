extends TileMap
class_name GWJ30_Map


const DEBUG := false
const CELL_SIZE := 16

const TILE_TO_ACTION_MAP := {
	0: GWJ30_TileAction_Wall,
	1: GWJ30_TileAction_Floor,
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
					if cell == 1: # Floor tile
						floor_tiles.append(key)
					set_cell(key[0], key[1], cell)
		room.queue_free()

	# Close off any potential gaps
	for floor_pos in floor_tiles:
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
						nav_points.push_back(Vector2(floor_pos[0], floor_pos[1]))
						var index: int = _nav_pos_to_index(Vector2(floor_pos[0], floor_pos[1]))
						assert(index >= 0, "Index must be 0 or greater")
						astar.add_point(index, Vector3(floor_pos[0], floor_pos[1], 0))
						continue
		actions[floor_pos] = GWJ30_TileAction_Wall.new()
		set_cell(floor_pos[0], floor_pos[1], 0)

	# Initialize navigation
	for from in nav_points:
		var from_index := _nav_pos_to_index(from)
		for rel_to in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]:
			var to: Vector2 = from + rel_to
			var to_index := _nav_pos_to_index(to)
			if astar.has_point(to_index):
				astar.connect_points(from_index, to_index, false)

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
		acts.push_back(actions[key])
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
