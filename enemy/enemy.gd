extends Sprite
class_name GWJ30_Enemy


export var map_path := NodePath()
export var player_path := NodePath()
export var heartbeat_sound_path := NodePath()
export var kill_sound_path := NodePath()
export var stop_beat_animation_path := NodePath()
onready var map: GWJ30_Map = get_node_or_null(map_path)
onready var player: GWJ30_Player = get_node(player_path)
onready var heartbeat_sound: AudioStreamPlayer2D = get_node(heartbeat_sound_path)
onready var kill_sound: AudioStreamPlayer2D = get_node(kill_sound_path)
onready var stop_beat_animation: AnimationPlayer = get_node(stop_beat_animation_path)

var state: GWJ30_EnemyState = GWJ30_EnemyState_Teleport.new()
var move_counter := 0


func _ready() -> void:
	# Deferred in case the player moves _after_
	var e := player.connect("move", self, "call_deferred", ["move"])
	call_deferred("_post_ready")


func _post_ready() -> void:
	# Move once already (teleport in this case)
	state = state.advance(map, player, self)
	# Start playing audio now to prevent the player from hearing one beat
	heartbeat_sound.play()


func move() -> void:
	_check_kill()
	# Make sure we don't get near the player if he has a candle
	# Use 1.51 instead of 1.5 to compensate for FP precision
	if player.illuminated and player.position.distance_squared_to(position) < 1.51 * 1.51:
		state = GWJ30_EnemyState_Teleport.new().advance(map, player, self)
	else:
		# Only advance once every 2 "ticks" so the player can always outrun
		# the enemy
		move_counter += 1
		move_counter %= 2
		if move_counter == 0:
			state = state.advance(map, player, self)
			assert(state != null, "State may not be null!")
	_check_kill()


func _check_kill() -> void:
	if player.position == position:
		# using == is fine, it is exact
		player.kill()
		kill_sound.play()
		heartbeat_sound.stop()


func player_escaped() -> void:
	stop_beat_animation.play("fade_out")
