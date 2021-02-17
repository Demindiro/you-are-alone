extends GWJ30_EnemyState
class_name GWJ30_EnemyState_Idle


func advance(_map: GWJ30_Map, _player: GWJ30_Player, _enemy) -> GWJ30_EnemyState:
	var c := randf()
	if c < 0.05:
		return GWJ30_EnemyState_Follow.new()
	elif c < 0.08:
		return GWJ30_EnemyState_Wander.new()
	elif c < 0.10:
		return GWJ30_EnemyState_Teleport.new()
	elif c < 0.14:
		return GWJ30_EnemyState_Attack.new()
	return self
