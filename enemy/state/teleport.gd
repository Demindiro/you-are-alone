extends GWJ30_EnemyState
class_name GWJ30_EnemyState_Teleport

func advance(map: GWJ30_Map, player: GWJ30_Player, enemy) -> GWJ30_EnemyState:
	for i in range(10):
		var pos := map.get_any_floor_point()
		# Try to stay at least 10 tiles away to be outside the audible range
		if player.position.distance_squared_to(pos) >= 10 * 10:
			enemy.position = pos
			break
	return load("res://enemy/state/idle.gd").new()
