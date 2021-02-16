extends Sprite
class_name GWJ30_Enemy


export var map_path := NodePath()
export var player_path := NodePath()
onready var map: GWJ30_Map = get_node(map_path)
onready var player: GWJ30_Player = get_node(player_path)

var state: GWJ30_EnemyState = GWJ30_EnemyState_Idle.new()
var move_counter := 0


func _ready() -> void:
	# Deferred in case the player moves _after_
	var e := player.connect("move", self, "call_deferred", ["move"])


func move() -> void:
	# Make sure we don't get near the player if he has a candle
	# Use 1.51 instead of 1.5 to compensate for FP precision
	if player.illuminated and player.position.distance_squared_to(position) < 1.51 * 1.51:
		state = GWJ30_EnemyState_Teleport.new().advance(map, player, self)
	else:
		# Only advance once every 3 "ticks" so the player can always outrun
		# the enemy
		move_counter += 1
		move_counter %= 3
		if move_counter == 0:
			state = state.advance(map, player, self)
			assert(state != null, "State may not be null!")
