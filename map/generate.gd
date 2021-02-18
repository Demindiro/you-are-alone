extends Node
class_name GWJ30_MapGenerate


signal done(map)


# Number indicates relative chance to spawn
const TILES := {
	preload("corner/corner_dl.tres"): 1,
	preload("corner/corner_lu.tres"): 1,
	preload("corner/corner_ur.tres"): 1,
	preload("corner/corner_rd.tres"): 1,

	preload("hall/hall_u.tres"): 2,
	preload("hall/hall_l.tres"): 2,

	preload("t_split/t_split_u.tres"): 1,
	preload("t_split/t_split_d.tres"): 1,
	preload("t_split/t_split_l.tres"): 1,
	preload("t_split/t_split_r.tres"): 1,

	preload("dining_room/dining_room.tres"): 0.5,
	preload("storage_room/storage_room.tres"): 0.75,
	preload("library/library.tres"): 0.25,
	preload("fountain/fountain.tres"): 0.5
}
#const TILES_PER_MAP := 256
const TILES_PER_MAP := 32

var _tiles := []
var _tile_table := []
var _tile_table_sum := 0.0


func _enter_tree() -> void:
	var time := OS.get_ticks_msec()
	for res in TILES:
		var c = TILES[res]
		_tile_table_sum += c
		_tile_table.push_back([_tile_table_sum, res])

	var map := GWJ30_Map.new()

	_tiles = [
		[Vector2(), _pop_random_tile(_tile_table.duplicate(), _tile_table_sum)]	
	]
	map.add_child(load(_tiles[0][1].scene_path).instance())
	var entrances := Array(_tiles[0][1].entrances)

	while len(_tiles) < TILES_PER_MAP:
		var tile_table := _tile_table.duplicate()
		var tile_table_sum := _tile_table_sum
		while len(tile_table) > 0:
			var do_break := false
			var tile_a := _pop_random_tile(tile_table, tile_table_sum)
			tile_table_sum -= TILES[tile_a]
			var entr_a := Array(tile_a.entrances)
			entrances.shuffle()
			entr_a.shuffle()
			while len(entr_a) > 0:
				var pos_a: Vector2 = entr_a.pop_back()
				var entr_b := entrances.duplicate()
				while len(entr_b) > 0:
					var pos_b: Vector2 = entr_b.pop_back()
					var rel_pos: Vector2 = pos_b - pos_a
					if not _is_valid(tile_a, rel_pos):
						_tiles.push_back([rel_pos, tile_a])
						var n: TileMap = load(tile_a.scene_path).instance()
						n.position = rel_pos
						entrances.erase(pos_b)
						map.add_child(n)
						for e in tile_a.entrances:
							e += rel_pos
							if e != pos_b:
								entrances.push_back(e)
						do_break = true
						break
				if do_break:
					break
			if do_break:
				break

	print("Generate time: ", OS.get_ticks_msec() - time, " ms")

	add_child(map)
	emit_signal("done", map)
	set_script(null)
	# TODO the below causes SIGSEGV, report this
	# Presumably because of the set_script(null) thing above
	#print("Generate time: ", OS.get_ticks_msec() - time, " ms")


func _pop_random_tile(tiles: Array, tiles_sum: float) -> GWJ30_RoomResource:
	var c := randf() * tiles_sum
	# This could be a binary search but w/e
	var i := 0
	for e in tiles:
		if c < e[0]:
			tiles.remove(i)
			return e[1]
		i += 1
	assert(false, "_tile_table_sum is out of range")
	return null


func _is_valid(room: GWJ30_RoomResource, pos: Vector2) -> bool:
	var rect_b := room.size
	rect_b.position += pos
	# TODO make a proper solution that doesn't assume the borders are walls/floors only
	rect_b.size -= Vector2(2, 2)
	rect_b.position += Vector2.ONE
	var entrances := room.entrances
	for tile in _tiles:
		var rect_a: Rect2 = tile[1].size
		rect_a.position += tile[0]
		if rect_b.intersects(rect_a):
			return true
		var erase_indices := PoolIntArray()
		for i in len(entrances):
			var e := entrances[i] + pos
			var rect_ar := rect_a
			# has_point doesn't include points on the bottom/right boundary. To prevent having
			# to fix this when that bug gets fixed, just use Vector2.ONE / 2
			rect_ar.size -= Vector2.ONE / 2
			if rect_ar.has_point(e):
				erase_indices.push_back(i)
		erase_indices.invert()
		for i in erase_indices:
			entrances.remove(i)
		if len(entrances) < 1:
			# Make sure there is always an opening
			# Note that the equation uses 1, because at least one entrance will overlap
			return true
	assert(len(entrances) != len(room.entrances), "There is no overlapping entrance!")
	return false
