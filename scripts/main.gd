extends Control
## Placeholder main scene. Replaced by the main menu (see the menu issue).


func _ready() -> void:
	%Version.text = "v%s" % ProjectSettings.get_setting("application/config/version")
	%PlayButton.pressed.connect(Game.go_to.bind(Game.BOARD_SCENE))


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:  # Android back on the main screen leaves the app
		get_tree().quit()
