extends SceneTree
## Renders a scene in a real window and saves a PNG. Used by tools/screenshot.sh.
## Godot's --write-movie doesn't capture CanvasLayer UI, which is why this exists.
## Args after `++`: <scene path> <output png> [frames to wait]


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 2:
		printerr("usage: tools/screenshot.sh <res://scene.tscn> <out.png> [frames]")
		quit(2)
		return
	root.add_child(load(args[0]).instantiate())
	var frames := int(args[2]) if args.size() > 2 else 20
	for i in frames:
		await process_frame
	var error := root.get_texture().get_image().save_png(args[1])
	quit(0 if error == OK else 1)
