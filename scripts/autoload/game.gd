extends Node
## Global game flow: input actions and scene navigation. Autoloaded as `Game`.

const MAIN_SCENE := "res://scenes/main.tscn"
const BOARD_SCENE := "res://scenes/board/board.tscn"

## Desktop controls, defined in code so they're readable and reviewable (instead of serialized in project.godot).
const INPUT_ACTIONS := {
	&"tilt_left": [KEY_A, KEY_LEFT],
	&"tilt_right": [KEY_D, KEY_RIGHT],
	&"tilt_up": [KEY_W, KEY_UP],
	&"tilt_down": [KEY_S, KEY_DOWN],
	&"calibrate": [KEY_C],
	&"toggle_debug": [KEY_F3],
}


func _ready() -> void:
	register_input_actions()


static func register_input_actions() -> void:
	for action: StringName in INPUT_ACTIONS:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action, 0.2)
		for keycode: Key in INPUT_ACTIONS[action]:
			var event := InputEventKey.new()
			event.physical_keycode = keycode
			InputMap.action_add_event(action, event)


func go_to(scene_path: String) -> void:
	get_tree().change_scene_to_file.call_deferred(scene_path)
