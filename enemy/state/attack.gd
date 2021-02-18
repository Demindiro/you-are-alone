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
	assert(len(path) > 0, "No path found!")
	if len(path) > 1:
		enemy.position = path[1]
	return self
