class_name TimeFormat
extends RefCounted
## Formats run times for the HUD and leaderboard as `hh:mm:ss:mmm`.


## Formats a duration in milliseconds, e.g. 3_723_045 -> "01:02:03:045".
## Negative input is clamped to zero. Hours keep growing past 99 rather than wrapping.
static func format_ms(total_ms: int) -> String:
	total_ms = maxi(total_ms, 0)
	var ms := total_ms % 1000
	var total_seconds := total_ms / 1000
	var seconds := total_seconds % 60
	var minutes := (total_seconds / 60) % 60
	var hours := total_seconds / 3600
	return "%02d:%02d:%02d:%03d" % [hours, minutes, seconds, ms]
