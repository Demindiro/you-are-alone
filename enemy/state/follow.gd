extends GWJ30_EnemyState
class_name GWJ30_EnemyState_Follow


func advance(map: GWJ30_Map, player: GWJ30_Player, enemy) -> GWJ30_EnemyState:
	if randf() < 0.02:
		return load("res://enemy/state/idle.gd").new()
		#return GWJ30_EnemyState_Idle.new()
	var path := map.get_point_path(enemy.position, player.position)
	if len(path) > 0:
		# Stay just outside "candle" ( == 3 tiles) range
		# It's actually just inside but the enemy is invisble so w/e
		# Also account for path length, we may be behind a wall
		if len(path) > 5 or player.position.distance_squared_to(enemy.position) > 3 * 3:
			enemy.position = path[0]
			path.remove(0)
	return self
