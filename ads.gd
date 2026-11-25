extends Node
# AdMob REWARDED ad for the Game Over "1-UP" button (Poing Studios godot-admob plugin, Android/iOS only).
# The plugin's classes are looked up by name at runtime, so this project still loads and runs when the plugin
# isn't installed (desktop, web, editor). In that case is_ready() is simply always false and the game falls
# back to the 200-coin 1-UP.

signal ready_changed          # an ad became available / unavailable
signal ad_finished(completed: bool)   # completed == the player earned the reward

const ENABLED := true         # master switch: set false to disable ads entirely
const USE_TEST_IDS := true    # MUST be false for release builds. Never tap your own live ads.
const UNIT_IDS := {
	"Android": {"test": "ca-app-pub-3940256099942544/5224354917", "prod": "ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY"},
	"iOS": {"test": "ca-app-pub-3940256099942544/1712485313", "prod": "ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY"}}
const RETRY_SECONDS := [15.0, 30.0, 60.0, 120.0]

var ad = null
var loading := false
var showing := false
var earned := false
var fails := 0
var retry_in := -1.0
var _on := false
var _listener = null
var _fs = null

func _ready() -> void:
	if not ENABLED or not (OS.get_name() == "Android" or OS.get_name() == "iOS"):
		return
	if _cls("MobileAds") == null or _cls("RewardedAdLoader") == null:
		push_warning("AdMob plugin not found - using coin-only 1-UP.")
		return
	_on = true
	_cls("MobileAds").initialize()
	_load()

func _cls(cname: String):
	for d in ProjectSettings.get_global_class_list():
		if d["class"] == cname:
			return load(d["path"])
	return null

func _unit() -> String:
	var u = UNIT_IDS[OS.get_name()]
	return u["test"] if USE_TEST_IDS else u["prod"]

func is_ready() -> bool:
	return _on and ad != null and not showing

func _load() -> void:
	if not _on or loading or ad != null:
		return
	loading = true
	var cb = _cls("RewardedAdLoadCallback").new()
	cb.on_ad_loaded = _on_loaded
	cb.on_ad_failed_to_load = _on_load_failed
	_cls("RewardedAdLoader").new().load(_unit(), _cls("AdRequest").new(), cb)

func _on_loaded(loaded_ad) -> void:
	loading = false
	fails = 0
	ad = loaded_ad
	_fs = _cls("FullScreenContentCallback").new()
	_fs.on_ad_dismissed_full_screen_content = _on_dismissed
	_fs.on_ad_failed_to_show_full_screen_content = _on_show_failed
	ad.full_screen_content_callback = _fs
	ready_changed.emit()

func _on_load_failed(_err = null) -> void:
	loading = false
	ad = null
	retry_in = RETRY_SECONDS[mini(fails, RETRY_SECONDS.size() - 1)]
	fails += 1
	ready_changed.emit()

func show_ad() -> void:
	if not is_ready():
		ad_finished.emit(false)
		return
	showing = true
	earned = false
	_listener = _cls("OnUserEarnedRewardListener").new()
	_listener.on_user_earned_reward = _on_earned
	ad.show(_listener)

func _on_earned(_item = null) -> void:
	earned = true

# The reward is paid out only after the ad closes, and only if the player actually earned it.
func _on_dismissed() -> void:
	_release()
	ad_finished.emit(earned)
	earned = false
	ready_changed.emit()
	_load()

func _on_show_failed(_err = null) -> void:
	_release()
	earned = false
	ad_finished.emit(false)
	ready_changed.emit()
	_load()

func _release() -> void:
	showing = false
	if ad != null:
		ad.destroy()
	ad = null
	_listener = null
	_fs = null

func _process(delta: float) -> void:
	if retry_in > 0.0:
		retry_in -= delta
		if retry_in <= 0.0:
			retry_in = -1.0
			_load()
