extends GWJ30_EnemyState
class_name GWJ30_EnemyState_Attack


func advance(map: GWJ30_Map, player: GWJ30_Player, enemy) -> GWJ30_EnemyState:
	print("COME ERE BOI")
	if randf() < 0.02:
		return load("res://enemy/state/idle.gd").new()
	if player.illuminated:
		# Don't attack player if he has a candle
		return GWJ30_EnemyState_Follow.new()
	var path := map.get_point_path(enemy.position, player.position)
	if len(path) > 0:
		enemy.position = path[1]
	else:
		assert(false, "No path found!")
	return self
