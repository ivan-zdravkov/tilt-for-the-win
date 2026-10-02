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
