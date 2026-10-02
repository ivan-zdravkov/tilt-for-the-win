class_name CameraFit
extends RefCounted
## Sizes a top-down orthographic camera so the whole board is visible on any screen shape.


## Returns the `Camera3D.size` (visible height, with `keep_aspect = KEEP_HEIGHT`) that fits a board of
## `board_size` (x = width, y = screen-vertical depth) plus `margin` on every side into a viewport whose
## width / height ratio is `viewport_aspect`.
static func ortho_height(board_size: Vector2, viewport_aspect: float, margin := 0.0) -> float:
	var width := board_size.x + margin * 2.0
	var height := board_size.y + margin * 2.0
	return maxf(height, width / maxf(viewport_aspect, 0.01))
