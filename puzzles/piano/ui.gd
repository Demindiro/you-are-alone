extends Control


const LENGTH := 4
const PITCHES := 3

export var low_pitch_path := NodePath()
export var medium_pitch_path := NodePath()
export var high_pitch_path := NodePath()
onready var low_pitch: AudioStreamPlayer = get_node(low_pitch_path)
onready var medium_pitch: AudioStreamPlayer = get_node(medium_pitch_path)
onready var high_pitch: AudioStreamPlayer = get_node(high_pitch_path)

export(Array, NodePath) var note_paths := []

export var timer_path := NodePath()
onready var timer: Timer = get_node(timer_path)

var progress := 0
var puzzle


func _ready() -> void:
	for i in len(puzzle.solution) - len(puzzle.notes):
		get_node(note_paths[-i - 1]).visible = false
	for i in len(puzzle.notes):
		if puzzle.notes[i] >= 0:
			get_node(note_paths[i]).get_child(puzzle.notes[i]).pressed = true


func play() -> void:
	progress = 0
	timer.start()
	play_note()


func play_note() -> void:
	_play_pitch(puzzle.solution[progress])
	progress += 1
	if progress == len(puzzle.solution):
		timer.stop()


func selected_pitch(pitch: int, note: int):
	_play_pitch(pitch)
	puzzle.set_note(note, pitch)


func _play_pitch(pitch: int) -> void:
	match pitch:
		0:
			low_pitch.play()
		1:
			medium_pitch.play()
		2:
			high_pitch.play()
		_:
			assert(false, "Invalid pitch")
