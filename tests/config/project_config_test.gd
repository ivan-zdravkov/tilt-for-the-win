extends GdUnitTestSuite
## Guards project settings that must not drift: identity that can't change after the first store upload,
## and export presets that must never contain signing credentials (the repo is public).

const BUNDLE_ID := "dev.zdravkov.tiltforthewin"
const KEYSTORE_KEYS := [
	"keystore/debug", "keystore/debug_user", "keystore/debug_password",
	"keystore/release", "keystore/release_user", "keystore/release_password",
]


func _load_presets() -> ConfigFile:
	var presets := ConfigFile.new()
	assert_int(presets.load("res://export_presets.cfg")).is_equal(OK)
	return presets


func _section_for_platform(presets: ConfigFile, platform: String) -> String:
	for section in presets.get_sections():
		if presets.get_value(section, "platform", "") == platform:
			return section
	return ""


func test_android_preset_has_no_signing_credentials() -> void:
	var presets := _load_presets()
	var section := _section_for_platform(presets, "Android")
	assert_str(section).is_not_empty()
	for key in KEYSTORE_KEYS:
		assert_str(presets.get_value(section + ".options", key, "")).override_failure_message(
			"%s must stay empty; CI injects it via GODOT_ANDROID_KEYSTORE_* env vars" % key).is_empty()


func test_bundle_ids_match_on_both_platforms() -> void:
	var presets := _load_presets()
	var android := _section_for_platform(presets, "Android")
	var ios := _section_for_platform(presets, "iOS")
	assert_str(presets.get_value(android + ".options", "package/unique_name")).is_equal(BUNDLE_ID)
	assert_str(presets.get_value(ios + ".options", "application/bundle_identifier")).is_equal(BUNDLE_ID)


func test_dev_only_files_are_excluded_from_exports() -> void:
	var presets := _load_presets()
	for platform in ["Android", "iOS"]:
		var filter: String = presets.get_value(_section_for_platform(presets, platform), "exclude_filter", "")
		assert_str(filter).contains("tests/*").contains("tools/*").contains("addons/gdUnit4/*")


func test_screen_is_locked_to_portrait() -> void:
	# Auto-rotation is unusable in a tilt game: lying the phone flat would flip the screen.
	assert_int(ProjectSettings.get_setting("display/window/handheld/orientation")).is_equal(
		DisplayServer.SCREEN_PORTRAIT)


func test_tilt_sensors_are_enabled() -> void:
	# Since Godot 4.4 mobile sensors are off by default; without these the board ignores tilting (bug found on Android).
	for sensor in ["gravity", "accelerometer"]:
		assert_bool(ProjectSettings.get_setting("input_devices/sensors/enable_" + sensor, false)).override_failure_message(
			"input_devices/sensors/enable_%s must be on, or Input reads zero on phones" % sensor).is_true()


func test_phones_get_smooth_edges_and_sharp_shadows() -> void:
	# The Mobile renderer has lower ".mobile" defaults that silently win on phones; the game looked pixelated without these.
	assert_int(ProjectSettings.get_setting("rendering/anti_aliasing/quality/msaa_3d")).is_equal(Viewport.MSAA_4X)
	assert_float(ProjectSettings.get_setting("rendering/scaling_3d/scale")).is_equal(1.0)
	assert_int(ProjectSettings.get_setting("rendering/lights_and_shadows/directional_shadow/size.mobile")).is_equal(4096)
	assert_int(ProjectSettings.get_setting(
		"rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality.mobile")).is_greater(0)
