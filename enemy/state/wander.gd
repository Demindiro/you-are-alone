extends GWJ30_EnemyState
class_name GWJ30_EnemyState_Wander

var path := PoolVector2Array()

func advance(map: GWJ30_Map, player: GWJ30_Player, enemy) -> GWJ30_EnemyState:
	var c := randf()
	if c < 0.05:
		return load("res://enemy/state/idle.gd").new()
	elif c < 0.07:
		return GWJ30_EnemyState_Follow.new()
	if len(path) == 0:
		path = map.get_point_path(enemy.position, map.get_any_floor_point())
	if len(path) > 0:
		enemy.position = path[0]
		path.remove(0)
	return self
