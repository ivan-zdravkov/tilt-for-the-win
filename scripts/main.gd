extends Control
## Placeholder main scene. Replaced by the main menu (see the menu issue).


func _ready() -> void:
	%Version.text = "v%s" % ProjectSettings.get_setting("application/config/version")
