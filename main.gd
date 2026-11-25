extends Node3D
# Root n Shooters - Godot 4 port (GDScript). Everything is built procedurally; no external assets.

const SfxS = preload("res://sfx.gd")
const AdsS = preload("res://ads.gd")
const N = 15
const CS = 140.0
const COST = 500
const FREE_MS = 6.0 * 3600.0 * 1000.0
const MAXHP = 3
# Bounce height (world units) of the hop animation. Models are authored at unit size and the root is scaled,
# so the code divides by the model's scale ("bs") to keep these values in world units.
const BOUNCE_PLAYER = 3.0   # in-game player hop (scaled by movement speed)
const BOUNCE_ENEMY = 2.5    # enemy / boss hop
const BOUNCE_MENU = 3.0     # character carousel + shop reveal (also multiplied by the display zoom)
const WL = ["dbl", "tri", "wide", "quad", "mega", "mdbl", "cross", "homing", "badger", "tow", "sky", "cannon", "zap", "cruze", "wand", "shield"]
const RB = ["#ff3b3b", "#ff9f1c", "#ffe14d", "#3ddc6e", "#2e86de", "#5b4bff", "#b05ce6"]
const COLS = ["#ff5a5f", "#ffd23f", "#3ddc6e", "#2e86de", "#b05ce6", "#ff9f1c"]
const BN = ["Big Bill Bison", "Vulture Vern", "Coyote Kid", "Rattler King", "Scorpion Mcgee", "Big Bear Bandit"]
const CHN = ["Crocodile Cowboy", "Armadillo Deputy", "Prospector Platypus", "Farmer Frog", "Mole Miner", "Rain Frog Johnson", "Possum Pete", "Lil Jim Bob", "Rascal Raccoon", "Jackalope Jack", "Prairie Dog Dan", "Horned Toad Hank", "Skunk Sally", "Roadrunner Rita", "Tortoise Tex"]
const ET = [
	{"hp": 1, "r": 14, "sp": 125, "pts": 10, "c": "#a67c3d", "w": "#2b2b2b", "b": "#e63946"},
	{"hp": 3, "r": 17, "sp": 90, "pts": 30, "c": "#4f7a3a", "w": "#c9a66b", "b": "#222222"},
	{"hp": 12, "r": 28, "sp": 55, "pts": 100, "c": "#2f5d3a", "w": "#111111", "b": "#ffd23f"},
	{"hp": 80, "r": 46, "sp": 40, "pts": 500, "c": "#1f4d2e", "w": "#111111", "b": "#ffd23f"},
	{"hp": 2, "r": 12, "sp": 150, "pts": 20, "c": "#a8532a", "w": "#222222", "b": "#222222"},
	{"hp": 2, "r": 14, "sp": 140, "pts": 25, "c": "#c9a06a", "w": "#a67c52", "b": "#ffd23f"},
	{"hp": 6, "r": 20, "sp": 50, "pts": 60, "c": "#e8a33d", "w": "#8b5a2b", "b": "#222222"},
	{"hp": 1, "r": 16, "sp": 0, "pts": 15, "c": "#a67c3d", "w": "#a67c3d", "b": "#a67c3d"},
	{"hp": 3, "r": 17, "sp": 80, "pts": 50, "c": "#3b6e4a", "w": "#222222", "b": "#e63946"}]

var sfx
var ads
var camera: Camera3D
var S = "menu"
var P = {}
var B = []
var EB = []
var E = []
var PT = []
var PK = []
var CR = []
var BX = []
var WG = []
var score = 0
var coins = 0
var t = 0.0
var wv = 0
var wq = []
var wt = 0.0
var wr = 1
var wa = 0.0
var shake = 0.0
var cam = Vector2.ZERO
var ck = 0.0
var eid = 0
var W = 1280.0
var H = 720.0
var SR = 700.0
var hw = 270.0
var hg = 330.0
var best = 0
var UN = {0: true}
var bank = 0
var lastFree = 0.0
var pmOpen = false
var busy = false
var chi = 0
var chs = 0.0
var CHM = []
var PM: Node3D
var CL = []
var GR: Node3D
var SHD: Node3D
var SAW: Node3D
var ZB: Node3D
# input
var mdown = false
var um = false
var tm = false
var T = {}
var swipe_x = null
# ui
var hud: Control
var menu: Control
var arrows: Control
var ov: Control
var pm: Control
var flash: ColorRect
var cn_l: Label
var dots_l: Label
var bk_l: Label
var bk3_l: Label
var pr_l: Label
var msg_l: Label
var b_play: Button
var b_snd: Button
var b_al: Button
var b_ar: Button
var b_sp: Button
var b_fr: Button
var b_up: Button
var WRAP = {}
# shop machine
var MR: Node3D
var MG: Node3D
var CRK: Node3D
var CAPS = []
var EX = []
var pz = {"st": "idle", "t": 0.0, "cap": null, "col": 0, "hv": null}

func hh(x, y) -> float:
	var n = sin(x * 127.1 + y * 311.7) * 43758.5453
	return n - floor(n)

func put(m, x, y, z):
	m.position = Vector3(x, y, z)
	add_child(m)
	return m

func keep(a: Array, f: Callable) -> Array:
	var out = []
	for o in a:
		if f.call(o):
			out.append(o)
		else:
			o.m.queue_free()
	return out

func rbc() -> String:
	return RB[randi() % 7]

# ---------------------------------------------------------------- setup
func _ready() -> void:
	randomize()
	sfx = SfxS.new()
	add_child(sfx)
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#e6c27e")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color.WHITE
	env.ambient_light_energy = .7
	var we = WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var dl = DirectionalLight3D.new()
	dl.light_energy = .75
	add_child(dl)
	dl.look_at_from_position(Vector3(-.6, 1.6, .9) * 10.0, Vector3.ZERO)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.near = 1.0
	camera.far = 4000.0
	add_child(camera)
	camera.current = true
	GR = Chars.inst("res://scenes/environment/ground.tscn")
	add_child(GR)
	_build_terrain()
	SHD = Chars.inst("res://scenes/effects/shield_bubble.tscn")
	SHD.visible = false
	add_child(SHD)
	SAW = Chars.inst("res://scenes/effects/saw.tscn")
	SAW.visible = false
	add_child(SAW)
	ZB = Chars.inst("res://scenes/effects/zap_beam.tscn")
	ZB.visible = false
	add_child(ZB)
	for i in CHN.size():
		var m: Node3D = Chars.inst("res://scenes/characters/char_%02d.tscn" % i, Chars.PLAYER_SCALE[i])
		m.visible = false
		add_child(m)
		CHM.append(m)
	_load_save()
	for i in CHN.size():
		if not UN.has(i):
			Chars.silhouette(CHM[i], true)
	_build_machine()
	_build_ui()
	ads = AdsS.new()
	add_child(ads)
	ads.ready_changed.connect(refresh_up)
	ads.ad_finished.connect(_on_ad_finished)
	get_viewport().size_changed.connect(rs)
	rs()
	pick(0)

func _build_terrain() -> void:
	for a in N * N:
		var g: Node3D = Chars.inst("res://scenes/environment/terrain_tile.tscn")
		add_child(g)
		CL.append({"g": g, "p": g.get_node("Patch"), "r": g.get_node("Rock"), "r2": g.get_node("Rock2"), "c": g.get_node("Cactus")})

func terrain() -> void:
	var ci = int(floor(cam.x / CS)) - 7
	var cj = int(floor(cam.y / CS)) - 7
	for a in N:
		for b in N:
			var i = ci + posmod(a - ci, N)
			var j = cj + posmod(b - cj, N)
			var m = CL[a * N + b]
			var h = hh(i, j)
			if h < .35:
				m.g.visible = false
				continue
			m.g.visible = true
			m.g.position = Vector3(i * CS + hh(j, i) * 60, 0, j * CS + hh(i + 5, j) * 60)
			m.p.visible = h < .55
			m.r.visible = h >= .55 and h < .61
			m.r2.visible = m.r.visible
			m.c.visible = h >= .8
			if m.p.visible:
				m.p.scale = Vector3(70 + hh(i + 9, j) * 60, 1, 60 + hh(j, i + 3) * 60)
				m.p.position.y = .5
			if m.r.visible:
				var w = 40 + hh(i, j + 4) * 30
				m.r.scale = Vector3(w, w * .7, w * .9)
				m.r.position = Vector3(0, w * .35, 0)
				m.r2.scale = Vector3(w * .5, w * .4, w * .5)
				m.r2.position = Vector3(w * .3, w * .2, w * .12)
			if m.c.visible:
				m.c.rotation.y = h * 20

func rk(i, j):
	var h = hh(i, j)
	if h < .55 or h >= .61:
		return null
	return {"x": i * CS + hh(j, i) * 60, "y": j * CS + hh(i + 5, j) * 60, "r": (40 + hh(i, j + 4) * 30) * .55}

func rock_push(o, r) -> bool:
	var hit = false
	var ci = int(floor(o.x / CS))
	var cj = int(floor(o.y / CS))
	for i in range(ci - 1, ci + 2):
		for j in range(cj - 1, cj + 2):
			var k = rk(i, j)
			if k == null:
				continue
			var dx = o.x - k.x
			var dy = o.y - k.y
			var d = sqrt(dx * dx + dy * dy)
			var m = k.r + r
			if d < m:
				var q = d if d > 0 else 1.0
				o.x = k.x + dx / q * m
				o.y = k.y + dy / q * m
				hit = true
	return hit

func rock_hit(x, y) -> bool:
	var ci = int(floor(x / CS))
	var cj = int(floor(y / CS))
	for i in range(ci - 1, ci + 2):
		for j in range(cj - 1, cj + 2):
			var k = rk(i, j)
			if k != null and Vector2(x - k.x, y - k.y).length() < k.r:
				return true
	return false

func rs() -> void:
	var sz = get_viewport().get_visible_rect().size
	W = sz.x
	H = sz.y
	if W < H:
		hw = 270.0
		hg = hw * H / W
		camera.keep_aspect = Camera3D.KEEP_WIDTH
	else:
		hg = 330.0
		hw = hg * W / H
		camera.keep_aspect = Camera3D.KEEP_HEIGHT
	SR = minf(800.0, Vector2(hw, hg / .63).length() + 40.0)

# ---------------------------------------------------------------- save
func _load_save() -> void:
	var cf = ConfigFile.new()
	if cf.load("user://save.cfg") == OK:
		var l = cf.get_value("s", "un", [0])
		UN = {}
		for i in l:
			UN[int(i)] = true
		UN[0] = true
		bank = int(cf.get_value("s", "bank", 0))
		lastFree = float(cf.get_value("s", "free", 0.0))
		best = int(cf.get_value("s", "best", 0))
		chi = int(cf.get_value("s", "char", 0))
		sfx.muted = bool(cf.get_value("s", "mute", false))
	if chi < 0 or chi >= CHN.size() or not UN.has(chi):
		chi = 0
	chs = chi

func save() -> void:
	var cf = ConfigFile.new()
	cf.set_value("s", "un", UN.keys())
	cf.set_value("s", "bank", bank)
	cf.set_value("s", "free", lastFree)
	cf.set_value("s", "best", best)
	cf.set_value("s", "char", chi)
	cf.set_value("s", "mute", sfx.muted)
	cf.save("user://save.cfg")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		save()

# ---------------------------------------------------------------- ui
func lbl(text: String, size: int = 22, col: Color = Color("#16324f")) -> Label:
	var l = Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	return l

func btn(text: String, cb: Callable, sec: bool = false, w: int = 110) -> Button:
	var b = Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(w, 52)
	b.add_theme_font_size_override("font_size", 20)
	for st in ["normal", "hover", "pressed", "disabled"]:
		var sb = StyleBoxFlat.new()
		var c = Color("#5a6b7d") if sec else Color("#ff5a5f")
		if st == "pressed":
			c = c.darkened(.15)
		if st == "disabled":
			c = c.darkened(.3)
		sb.bg_color = c
		sb.set_corner_radius_all(6)
		sb.border_width_bottom = 5
		sb.border_color = c.darkened(.35)
		b.add_theme_stylebox_override(st, sb)
	b.add_theme_color_override("font_color", Color.WHITE)
	b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, .5))
	b.pressed.connect(cb)
	return b

func wrapb(title: String, b: Button, id: String) -> VBoxContainer:
	var v = VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	var l = lbl(title, 11)
	v.add_child(l)
	v.add_child(b)
	WRAP[id] = v
	return v

func panel() -> PanelContainer:
	var p = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(1, 1, 1, .92)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 12
	sb.content_margin_bottom = 16
	sb.shadow_color = Color(.35, .23, .08, .35)
	sb.shadow_size = 5
	sb.shadow_offset = Vector2(0, 5)
	p.add_theme_stylebox_override("panel", sb)
	p.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	return p

func full(c: Control) -> void:
	c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _build_ui() -> void:
	var cl = CanvasLayer.new()
	add_child(cl)
	hud = Control.new()
	full(hud)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.draw.connect(_hud_draw)
	cl.add_child(hud)
	# ---- menu
	menu = MarginContainer.new()
	full(menu)
	menu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for s in ["left", "right", "top", "bottom"]:
		menu.add_theme_constant_override("margin_" + s, 16)
	cl.add_child(menu)
	var vb = VBoxContainer.new()
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu.add_child(vb)
	var title = lbl("ROOT N\nSHOOTERS", 44, Color("#ffd23f"))
	title.add_theme_color_override("font_outline_color", Color("#24140a"))
	title.add_theme_constant_override("outline_size", 14)
	vb.add_child(title)
	var sp = Control.new()
	sp.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_child(sp)
	var pn = panel()
	vb.add_child(pn)
	var pv = VBoxContainer.new()
	pn.add_child(pv)
	pv.add_child(lbl("PICK", 11))
	cn_l = lbl("", 22)
	pv.add_child(cn_l)
	dots_l = lbl("", 12)
	pv.add_child(dots_l)
	bk_l = lbl("", 20)
	pv.add_child(bk_l)
	var row = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	pv.add_child(row)
	b_play = btn("PLAY", start, false, 130)
	b_snd = btn("SOUND ON", _toggle_snd, true, 130)
	row.add_child(wrapb("PLAY", b_play, "play"))
	row.add_child(wrapb("SHOP", btn("SHOP", open_shop, true, 100), "shop"))
	row.add_child(wrapb("SOUND", b_snd, "snd"))
	b_al = btn("<", func(): pick(-1), true, 60)
	b_ar = btn(">", func(): pick(1), true, 60)
	arrows = Control.new()
	full(arrows)
	arrows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(arrows)
	for b in [b_al, b_ar]:
		b.custom_minimum_size = Vector2(60, 70)
		arrows.add_child(b)
	b_al.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
	b_ar.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	b_al.position.x += 10
	b_ar.position.x -= 10
	# ---- game over
	ov = CenterContainer.new()
	full(ov)
	ov.visible = false
	cl.add_child(ov)
	var op = panel()
	ov.add_child(op)
	var ob = VBoxContainer.new()
	op.add_child(ob)
	ob.add_child(lbl("GAME OVER", 28, Color("#ff7b7b")))
	msg_l = lbl("", 22)
	ob.add_child(msg_l)
	var orow = HBoxContainer.new()
	orow.add_theme_constant_override("separation", 10)
	ob.add_child(orow)
	b_up = btn("1-UP 200", one_up, true, 120)
	orow.add_child(wrapb("1-UP", b_up, "up"))
	orow.add_child(wrapb("AGAIN", btn("AGAIN", start, false, 110), "again"))
	orow.add_child(wrapb("HOME", btn("HOME", go_home, true, 100), "home"))
	# ---- shop
	pm = MarginContainer.new()
	full(pm)
	pm.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pm.visible = false
	for s in ["left", "right", "top", "bottom"]:
		pm.add_theme_constant_override("margin_" + s, 16)
	cl.add_child(pm)
	var pvb = VBoxContainer.new()
	pvb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pm.add_child(pvb)
	var sp2 = Control.new()
	sp2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sp2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pvb.add_child(sp2)
	var pp = panel()
	pvb.add_child(pp)
	var ppv = VBoxContainer.new()
	pp.add_child(ppv)
	bk3_l = lbl("", 20)
	ppv.add_child(bk3_l)
	pr_l = lbl("", 20)
	pr_l.custom_minimum_size.y = 28
	ppv.add_child(pr_l)
	var prow = HBoxContainer.new()
	prow.alignment = BoxContainer.ALIGNMENT_CENTER
	prow.add_theme_constant_override("separation", 8)
	ppv.add_child(prow)
	b_sp = btn("BUY 500", func(): spin(false), false, 110)
	b_fr = btn("FREE", func(): spin(true), false, 130)
	prow.add_child(wrapb("BUY", b_sp, "sp"))
	prow.add_child(wrapb("FREE", b_fr, "fr"))
	prow.add_child(wrapb("OPEN", btn("OPEN", open_cap, false, 100), "op"))
	prow.add_child(wrapb("OK", btn("OK", shop_ok, false, 100), "ok"))
	prow.add_child(wrapb("BACK", btn("BACK", shop_back, true, 100), "bk2"))
	flash = ColorRect.new()
	full(flash)
	flash.color = Color(1, 1, 1, 0)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(flash)
	var tm_ = Timer.new()
	tm_.wait_time = 1.0
	tm_.autostart = true
	tm_.timeout.connect(pr_ui)
	add_child(tm_)
	show_btns([])
	_snd_label()

func set_menu(v: bool) -> void:
	menu.visible = v
	arrows.visible = v

func _snd_label() -> void:
	b_snd.text = "SOUND OFF" if sfx.muted else "SOUND ON"

func _toggle_snd() -> void:
	sfx.muted = not sfx.muted
	save()
	_snd_label()
	if not sfx.muted:
		sfx.blip(600, 900)

func show_btns(ids: Array) -> void:
	for id in ["sp", "fr", "bk2", "op", "ok"]:
		WRAP[id].visible = ids.has(id)

func _hud_draw() -> void:
	var f = hud.get_theme_default_font()
	var active = S == "play" or S == "over"
	if active and not P.is_empty():
		for i in maxi(0, P.hp):
			_heart(Vector2(26 + i * 30, 30))
		hud.draw_string_outline(f, Vector2(0, 38), str(score), HORIZONTAL_ALIGNMENT_CENTER, W, 28, 6, Color("#06284d"))
		hud.draw_string(f, Vector2(0, 38), str(score), HORIZONTAL_ALIGNMENT_CENTER, W, 28, Color.WHITE)
		var ct = str(coins)
		var tw = f.get_string_size(ct, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
		hud.draw_rect(Rect2(W - 16 - tw - 26, 14, 18, 18), Color("#ffd23f"))
		hud.draw_rect(Rect2(W - 16 - tw - 26, 14, 18, 18), Color("#b8860b"), false, 2.0)
		hud.draw_string_outline(f, Vector2(W - 16 - tw, 34), ct, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, 6, Color("#06284d"))
		hud.draw_string(f, Vector2(W - 16 - tw, 34), ct, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color.WHITE)
	# boss bar (new in this version)
	if S == "play":
		for e in E:
			if e.ty == 3 and e.hp > 0:
				var bw = minf(W * .72, 320.0)
				var bxp = (W - bw) / 2.0
				var nm: String = BN[e.v]
				hud.draw_string_outline(f, Vector2(bxp, 62), nm, HORIZONTAL_ALIGNMENT_CENTER, bw, 16, 6, Color("#24140a"))
				hud.draw_string(f, Vector2(bxp, 62), nm, HORIZONTAL_ALIGNMENT_CENTER, bw, 16, Color.WHITE)
				hud.draw_rect(Rect2(bxp, 68, bw, 20), Color("#24140a"))
				hud.draw_rect(Rect2(bxp + 3, 71, (bw - 6) * clampf(e.hp / e.mhp, 0, 1), 14), Color("#ff4d6d"))
				break
	if tm and S == "play":
		for s in ["L", "R"]:
			if not T.has(s):
				var hx = W * .2 if s == "L" else W * .8
				var hy = H * .78
				hud.draw_arc(Vector2(hx, hy), 60, 0, TAU, 40, Color(1, 1, 1, .45), 4.0)
	for s in T:
		var o = T[s]
		hud.draw_arc(Vector2(o.ox, o.oy), 60, 0, TAU, 40, Color(1, 1, 1, .7), 4.0)
		var v = stick(o)
		hud.draw_rect(Rect2(o.ox + v.x * 60 - 18, o.oy + v.y * 60 - 18, 36, 36), Color(1, 1, 1, .6))

func _heart(c: Vector2) -> void:
	var col = Color("#ff4d6d")
	hud.draw_circle(c + Vector2(-6, -4), 7, col)
	hud.draw_circle(c + Vector2(6, -4), 7, col)
	hud.draw_colored_polygon(PackedVector2Array([c + Vector2(-12.5, -1), c + Vector2(12.5, -1), c + Vector2(0, 14)]), col)

# ---------------------------------------------------------------- menu / carousel
func pick(d: int) -> void:
	if d != 0 and pmOpen:
		return
	if d != 0:
		sfx.blip(600, 900)
	chi = clampi(chi + d, 0, CHN.size() - 1)
	var lk = not UN.has(chi)
	cn_l.text = "???" if lk else CHN[chi]
	b_play.disabled = lk
	b_play.text = "LOCKED" if lk else "PLAY"
	bk_l.text = "COINS  %d" % bank
	var ds = ""
	for i in CHN.size():
		ds += "●" if i == chi else "○"
	dots_l.text = ds
	b_al.modulate.a = 1.0 if chi > 0 else .3
	b_ar.modulate.a = 1.0 if chi < CHN.size() - 1 else .3

func carousel() -> void:
	if pmOpen:
		return
	var mn = S == "menu"
	chs += (chi - chs) * .15
	for i in CHM.size():
		var m: Node3D = CHM[i]
		if mn:
			var d = i - chs
			var near = absf(d) < .5
			var f = 1.3 + 1.3 * maxf(0.0, 1.0 - absf(d))
			m.visible = true
			m.scale = Vector3(f, f, f) * m.get_meta("bs")
			m.position = Vector3(.7071 * d * 120, 0, -.7071 * d * 120)
			m.rotation.y = -.785 + (sin(ck * 2) * .5 if near else 0.0)
			m.get_meta("inner").position.y = absf(sin(ck * 5)) * BOUNCE_MENU / m.get_meta("bs") if near else 0.0
			m.get_meta("tail").rotation.y = sin(ck * 6) * .4
		else:
			m.visible = i == chi and S == "play" and not (P.inv > 0 and int(floor(t * 20)) % 2 == 1)

# ---------------------------------------------------------------- input
func kd(k) -> bool:
	return Input.is_physical_key_pressed(k)

func _input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo:
		if S == "menu" and not pmOpen:
			if e.physical_keycode == KEY_LEFT or e.physical_keycode == KEY_A: pick(-1)
			if e.physical_keycode == KEY_RIGHT or e.physical_keycode == KEY_D: pick(1)
		if (e.physical_keycode == KEY_ENTER or e.physical_keycode == KEY_SPACE) and S != "play" and not pmOpen:
			start()
	elif e is InputEventMouseMotion and e.device != InputEvent.DEVICE_ID_EMULATION:
		um = true
	elif e is InputEventMouseButton and e.device != InputEvent.DEVICE_ID_EMULATION:
		if e.button_index == MOUSE_BUTTON_LEFT:
			mdown = e.pressed
			um = true
	elif e is InputEventScreenTouch:
		if e.pressed:
			if S == "play":
				tm = true
				um = false
				var s = "L" if e.position.x < W / 2 else "R"
				if not T.has(s):
					T[s] = {"id": e.index, "ox": e.position.x, "oy": e.position.y, "x": e.position.x, "y": e.position.y}
			elif S == "menu" and not pmOpen:
				swipe_x = e.position.x
		else:
			for s in T.keys():
				if T[s].id == e.index:
					T.erase(s)
			if S == "menu" and swipe_x != null:
				var d: float = e.position.x - swipe_x
				if absf(d) > 40:
					pick(1 if d < 0 else -1)
				swipe_x = null
	elif e is InputEventScreenDrag:
		for s in T:
			if T[s].id == e.index:
				T[s].x = e.position.x
				T[s].y = e.position.y

func stick(s) -> Vector2:
	var dx = s.x - s.ox
	var dy = s.y - s.oy
	var m = sqrt(dx * dx + dy * dy)
	var r = 60.0
	if m < 8:
		return Vector2.ZERO
	var k = minf(m, r) / r
	return Vector2(dx / m * k, dy / m * k)

func to_w(sx, sy) -> Vector2:
	return Vector2((sx + sy) * .7071, (sy - sx) * .7071)

func mouse_world():
	var mp = get_viewport().get_mouse_position()
	var o = camera.project_ray_origin(mp)
	var n = camera.project_ray_normal(mp)
	return Plane(Vector3.UP, 16.0).intersects_ray(o, n)

# ---------------------------------------------------------------- game flow
func clear_world() -> void:
	for a in [B, EB, E, PK, PT, CR, BX, WG]:
		for o in a:
			o.m.queue_free()
	B = []; EB = []; E = []; PK = []; PT = []; CR = []; BX = []; WG = []
	T.clear()

func start() -> void:
	if pmOpen or not UN.has(chi):
		return
	clear_world()
	P = {"x": 0.0, "y": 0.0, "vx": 0.0, "vy": 0.0, "hp": MAXHP, "ang": -PI / 2, "cool": 0.0, "inv": 0.0, "pw": 0.0, "w": {}, "wc": {}, "sh": 0, "shT": 0.0, "sawT": 0.0, "sawOn": false, "zt": 0.0, "rev": false}
	ZB.visible = false
	score = 0; coins = 0; t = 0.0; wv = 0; wq = []; wt = 1.5; wr = 1; shake = 0.0
	cam = Vector2.ZERO
	S = "play"
	ov.visible = false
	set_menu(false)

func over() -> void:
	S = "over"
	save()
	sfx.over()
	if score > best:
		best = score
		save()
	msg_l.text = "%d\nBEST %d      COINS +%d" % [score, best, coins]
	refresh_up()
	ov.visible = true

func refresh_up() -> void:
	if S != "over":
		return
	WRAP["up"].visible = not P.rev   # one 1-UP per round (coins or ad)
	if P.rev:
		return
	if ads.is_ready():
		b_up.text = "1-UP: AD"
		b_up.disabled = false
	else:
		b_up.text = "1-UP 200"
		b_up.disabled = bank < 200 or ads.showing

func one_up() -> void:
	if S != "over" or ads.showing or P.rev:
		return
	if ads.is_ready():
		b_up.disabled = true
		ads.show_ad()
		return
	if bank < 200:
		return
	bank -= 200
	save()
	_grant_one_up()

func _on_ad_finished(completed: bool) -> void:
	if S != "over" or P.rev:
		return
	if completed:
		_grant_one_up()
	else:
		refresh_up()

func _grant_one_up() -> void:
	P.rev = true
	P.hp = MAXHP
	P.inv = 2.5
	if P.w.has("shield"):
		P.sh = 1
	for b in EB:
		b.m.queue_free()
	EB = []
	for e in E:
		var dx = e.x - P.x
		var dy = e.y - P.y
		var d = maxf(sqrt(dx * dx + dy * dy), .001)
		if d < 320 and e.ty != 3:
			e.x = P.x + dx / d * 320
			e.y = P.y + dy / d * 320
	S = "play"
	ov.visible = false
	sfx.heart()

func go_home() -> void:
	clear_world()
	S = "menu"
	ov.visible = false
	set_menu(true)
	pick(0)

func boom(x, y, c, n, sp) -> void:
	for i in n:
		var a = randf() * TAU
		var v = randf() * sp
		var s = 4 + randf() * 7
		PT.append({"x": x, "y": y, "h": 16.0, "vh": (randf() - .3) * 160, "vx": cos(a) * v, "vy": sin(a) * v, "l": .6, "L": .6, "s": s, "m": put(Chars.bx(s, s, s, c), x, 16, y)})

func hurt() -> void:
	if P.inv > 0:
		return
	if P.w.has("shield") and P.sh > 0:
		P.sh = 0
		P.shT = [0, 5, 3.5, 2.5][P.w.shield]
		P.inv = .6
		shake = 6
		boom(P.x, P.y, "#7fe3ff", 10, 200)
		sfx.pow_up()
		return
	P.hp -= 1
	sfx.hurt()
	P.inv = 1.3
	shake = 14
	boom(P.x, P.y, "#ffffff", 14, 240)
	if P.hp <= 0:
		boom(P.x, P.y, "#ff5a5f", 40, 360)
		over()

func ebul(x, y, a, sp) -> void:
	sfx.es()
	EB.append({"x": x, "y": y, "vx": cos(a) * sp, "vy": sin(a) * sp, "l": 4.0, "m": put(Chars.bx(10, 10, 10, "#e63946"), x, 16, y)})

func pk(x, y, k) -> void:
	var nm = {0: "pickup_coin", 1: "pickup_heart", 3: "pickup_gun", 4: "pickup_wingman"}[k]
	PK.append({"x": x, "y": y, "k": k, "l": 12.0, "m": put(Chars.inst("res://scenes/pickups/%s.tscn" % nm), x, 20, y)})

# ---------------------------------------------------------------- boxes / wingmen / weapons
func box_mesh(k: String) -> Node3D:
	return Chars.inst("res://scenes/pickups/box_%s.tscn" % ("blue" if k == "b" else "orange"))

func spawn_box(k: String) -> void:
	var a = randf() * TAU
	var x = P.x + cos(a) * 280
	var y = P.y + sin(a) * 280
	BX.append({"x": x, "y": y, "k": k, "hp": 4, "l": 40.0, "fl": 0.0, "vx": (randf() - .5) * 30, "vy": (randf() - .5) * 30, "m": put(box_mesh(k), x, 14, y)})

func open_box(q) -> void:
	q.hp = 0
	pk(q.x, q.y, 3 if q.k == "b" else 4)
	boom(q.x, q.y, "#4aa3ff" if q.k == "b" else "#ff9f1c", 16, 260)
	sfx.boom(false)
	shake = maxf(shake, 4)

func box_hit(x, y, r, dmg) -> void:
	for q in BX:
		if q.hp > 0 and Vector2(q.x - x, q.y - y).length() < r + 18:
			q.hp -= dmg
			q.fl = .1
			sfx.hit()
			if q.hp <= 0:
				open_box(q)

func grant_gun() -> void:
	var pool = WL.filter(func(i): return i != "shield")
	var sh = P.w.get("shield", 0)
	var id: String = pool[randi() % pool.size()]
	if sh == 0 and randf() < .08:
		id = "shield"
	if id == "shield":
		P.w["shield"] = 1
		P.sh = 1
		return
	var cur = null
	for k in P.w:
		if k != "shield":
			cur = k
	if cur == id:
		P.w[id] = mini(3, P.w[id] + 1)
	else:
		P.w = {"shield": sh} if sh != 0 else {}
		P.w[id] = 1
		P.wc = {}

func grant_wing() -> void:
	if WG.size() >= 3:
		WG[0].m.queue_free()
		WG.pop_front()
	var k = randi() % 3
	WG.append({"k": k, "l": 30 + randf() * 30, "cd": 0.0, "x": P.x, "y": P.y, "m": put(Chars.inst("res://scenes/wingmen/wingman_%d.tscn" % k, 11.0), P.x, 0, P.y)})

func bl(x, y, a, sp, o: Dictionary = {}):
	var m = Chars.bx(o.get("w", 20), o.get("h", 6), o.get("d", 6), o.get("c", "#ffe066"))
	m.rotation.y = -a
	var nv = o.get("nv", false)
	var b = {"x": x, "y": y, "vx": cos(a) * sp + (0.0 if nv else P.vx * .3), "vy": sin(a) * sp + (0.0 if nv else P.vy * .3),
		"l": .7, "dmg": 1, "pr": 0, "hs": {}, "type": "gun", "c": "#ffe066", "hm": 0.0, "wob": 0, "pull": 0.0, "ex": 0.0, "edm": 0, "kb": 0.0, "d": false, "m": m}
	for k in o:
		if k != "w" and k != "h" and k != "d":
			b[k] = o[k]
	put(m, 0, 16, 0)
	B.append(b)
	return b

func vsh(x0, y0, px, py, off, ang, sp, oo) -> void:
	bl(x0 + px * off, y0 + py * off, ang, sp, oo)

func volley() -> void:
	var a: float = P.ang
	var px = -sin(a)
	var py = cos(a)
	var L: Dictionary = P.w
	var x0: float = P.x + cos(a) * 30
	var y0: float = P.y + sin(a) * 30
	var mg: int = L.get("mega", 0)
	var o = {"c": "#4aa3ff", "w": 24, "h": 8, "d": 8, "dmg": 1 + mg} if mg > 0 else {}
	var mo = {"c": "#4aa3ff", "w": 24, "h": 8, "d": 8, "dmg": 1 + L.get("mdbl", 0)}
	vsh(x0, y0, px, py, 0, a, 720, o)
	for i in range(1, L.get("dbl", 0) + 1):
		vsh(x0, y0, px, py, 9 * i, a, 720, o)
		vsh(x0, y0, px, py, -9 * i, a, 720, o)
	for i in range(1, L.get("tri", 0) + 1):
		vsh(x0, y0, px, py, 14 * i, a, 720, o)
		vsh(x0, y0, px, py, -14 * i, a, 720, o)
		vsh(x0, y0, px, py, 0, a, 800, o)
	for i in range(1, L.get("wide", 0) + 1):
		vsh(x0, y0, px, py, 0, a + .15 * i, 720, o)
		vsh(x0, y0, px, py, 0, a - .15 * i, 720, o)
	for i in range(1, L.get("quad", 0) * 2 + 1):
		for f in [-21, -7, 7, 21]:
			vsh(x0, y0, px, py, f, a, 720 + 40 * i, o)
	if L.has("mdbl"):
		vsh(x0, y0, px, py, 10, a, 720, mo)
		vsh(x0, y0, px, py, -10, a, 720, mo)
	if L.has("cross"):
		for q in [1.5708, 3.1416, -1.5708]:
			vsh(x0, y0, px, py, 0, a + q, 720, o)
		if L["cross"] > 1:
			for q in [.7854, -.7854, 2.356, -2.356]:
				vsh(x0, y0, px, py, 0, a + q, 720, o)

func explode(x, y, r, dmg, type) -> void:
	box_hit(x, y, r, dmg)
	boom(x, y, "#ff9f1c", 18, 300)
	boom(x, y, "#ffe066", 8, 200)
	shake = maxf(shake, 5)
	sfx.boom(false)
	for e in E:
		if e.hp > 0:
			var dx = e.x - x
			var dy = e.y - y
			var d = sqrt(dx * dx + dy * dy)
			if d < r + ET[e.ty].r:
				e.hp -= dmg
				e.fl = .08
				e.by = type
				if e.ty != 3:
					var dd = d if d > 0 else 1.0
					e.x += dx / dd * 30
					e.y += dy / dd * 30
				if e.hp <= 0:
					kill(e)

func hit_e(b, e) -> void:
	e.hp -= b.dmg
	sfx.hit()
	e.fl = .08
	b.hs[e.id] = true
	e.by = b.type
	boom(b.x, b.y, b.c, 3, 120)
	if b.kb != 0:
		var v = maxf(Vector2(b.vx, b.vy).length(), .001)
		e.x += b.vx / v * b.kb
		e.y += b.vy / v * b.kb
	if b.ex > 0 and not b.d:
		explode(b.x, b.y, b.ex, b.edm, b.type)
	if b.pr > 0:
		b.pr -= 1
	else:
		b.d = true
	if e.hp <= 0:
		kill(e)

func bupd(b, dt) -> void:
	if b.hm > 0:
		var best_e = null
		var bd = 1e9
		for e in E:
			if e.hp > 0 and not b.hs.has(e.id):
				var d = Vector2(e.x - b.x, e.y - b.y).length()
				if d < bd:
					bd = d
					best_e = e
		if best_e != null:
			var sp = Vector2(b.vx, b.vy).length()
			var ca = atan2(b.vy, b.vx)
			var d = wrapf(atan2(best_e.y - b.y, best_e.x - b.x) - ca, -PI, PI)
			ca += clampf(d, -b.hm * dt, b.hm * dt)
			b.vx = cos(ca) * sp
			b.vy = sin(ca) * sp
	if b.wob != 0:
		var sp = Vector2(b.vx, b.vy).length()
		var ca = atan2(b.vy, b.vx) + sin(t * 18 + b.x * .1) * 3 * dt
		b.vx = cos(ca) * sp
		b.vy = sin(ca) * sp
	if b.pull > 0:
		for e in E:
			if e.hp > 0 and e.ty != 3 and Vector2(e.x - b.x, e.y - b.y).length() < b.pull:
				var dv = Vector2(b.x - e.x, b.y - e.y)
				var d = maxf(dv.length(), .001)
				e.x += dv.x / d * 160 * dt
				e.y += dv.y / d * 160 * dt
	b.x += b.vx * dt
	b.y += b.vy * dt
	b.l -= dt
	if b.hm > 0 or b.wob != 0:
		b.m.rotation.y = -atan2(b.vy, b.vx)
	for q in BX:
		if q.hp > 0 and not b.d and Vector2(b.x - q.x, b.y - q.y).length() < 24:
			q.hp -= b.dmg
			q.fl = .1
			sfx.hit()
			boom(b.x, b.y, "#ffffff", 3, 100)
			if b.pr > 0:
				b.pr -= 1
			else:
				b.d = true
			if q.hp <= 0:
				open_box(q)
	if rock_hit(b.x, b.y):
		if b.ex > 0 and not b.d:
			explode(b.x, b.y, b.ex, b.edm, b.type)
		b.d = true
		boom(b.x, b.y, "#b3a89c", 3, 90)
	elif b.l <= 0 and b.ex > 0 and not b.d:
		explode(b.x, b.y, b.ex, b.edm, b.type)
		b.d = true

func zap_fire(n) -> void:
	var a: float = P.ang
	var cx = cos(a)
	var cy = sin(a)
	for q in BX:
		if q.hp > 0:
			var dx = q.x - P.x
			var dy = q.y - P.y
			var t0 = dx * cx + dy * cy
			var pp = absf(-dx * cy + dy * cx)
			if t0 > 0 and t0 < 440 and pp < 32:
				q.hp -= 4
				q.fl = .1
				if q.hp <= 0:
					open_box(q)
	ZB.visible = true
	P.zt = .22
	sfx.tone(900, .25, "sawtooth", .1, 150)
	for e in E:
		if e.hp > 0:
			var dx = e.x - P.x
			var dy = e.y - P.y
			var t0 = dx * cx + dy * cy
			var pp = absf(-dx * cy + dy * cx)
			if t0 > 0 and t0 < 440 and pp < ET[e.ty].r + 14:
				e.hp -= 3 + n * 2
				e.fl = .08
				e.by = "zap"
				boom(e.x, e.y, "#bff7ff", 4, 150)
				if e.hp <= 0:
					kill(e)

func critter(e) -> void:
	var m = Chars.inst("res://scenes/critters/critter_%d.tscn" % (randi() % 4))
	var a = randf() * TAU
	CR.append({"x": e.x, "y": e.y, "vx": cos(a) * 110, "vy": sin(a) * 110, "l": 2.2, "m": put(m, e.x, 0, e.y)})
	boom(e.x, e.y, "#ff7bf0", 8, 160)

func wfire(dt) -> void:
	var a: float = P.ang
	var cx = cos(a)
	var cy = sin(a)
	var x0: float = P.x + cx * 30
	var y0: float = P.y + cy * 30
	var L: Dictionary = P.w
	var c: Dictionary = P.wc
	for id in L:
		c[id] = c.get(id, 0.0) - dt
		if c[id] > 0:
			continue
		var n: int = L[id]
		var f = pow(2.0, n - 1)
		match id:
			"homing":
				c[id] = .8 / f
				bl(x0, y0, a, 330, {"type": id, "c": "#ff6b35", "w": 16, "h": 8, "d": 8, "l": 2.2, "dmg": 2, "hm": 6.0})
			"badger":
				c[id] = 1.0 / f
				bl(x0, y0, a, 200, {"type": id, "c": "#dcdce6", "w": 16, "h": 10, "d": 10, "l": 3.0, "dmg": 3, "pr": 2, "hm": 3.0})
			"sky":
				c[id] = .45
				bl(x0, y0, a + (randf() - .5) * .5, 420, {"type": id, "c": "#ff4dd2", "w": 12, "h": 8, "d": 8, "l": 1.4, "dmg": 2, "wob": 1, "ex": 36.0 + 8 * n, "edm": 1})
			"cannon":
				c[id] = .4
				for i in range(-1, 2):
					bl(x0 - cy * i * 14, y0 + cx * i * 14, a, 520, {"type": id, "c": "#3a3a44", "w": 14, "h": 14, "d": 14, "l": .9, "dmg": 2, "pr": 99})
			"zap":
				c[id] = 1.4 / f
				zap_fire(n)
			"cruze":
				c[id] = 2.2 / f
				bl(x0, y0, a, 150, {"type": id, "c": "#8a8a9a", "w": 22, "h": 10, "d": 10, "l": 1.6, "dmg": 3, "ex": 90.0 + 10 * n, "edm": 4, "nv": true})
			"tow":
				c[id] = 2.0 / f
				bl(x0, y0, a, 260, {"type": id, "c": "#e0a43a", "w": 22, "h": 14, "d": 14, "l": 1.2, "dmg": 2, "ex": 70.0, "edm": 4, "pull": 90.0, "nv": true})
			"wand":
				c[id] = .55 / f
				bl(x0, y0, a, 430, {"type": id, "c": "#ff7bf0", "w": 12, "h": 12, "d": 12, "l": 2.0, "dmg": 2, "hm": 7.0})
		if c[id] > 0:
			sfx.launch()

func wupd(dt, fire) -> void:
	if fire:
		wfire(dt)
	P.sawOn = fire and P.w.has("saw")
	P.sawT -= dt
	if P.sawOn and P.sawT <= 0:
		P.sawT = .1
		var sx: float = P.x + cos(P.ang) * 40
		var sy: float = P.y + sin(P.ang) * 40
		box_hit(sx, sy, 36, P.w.saw)
		for e in E:
			if e.hp > 0 and Vector2(e.x - sx, e.y - sy).length() < 36 + ET[e.ty].r:
				e.hp -= P.w.saw
				e.fl = .05
				e.by = "saw"
				sfx.hit()
				boom(e.x, e.y, "#e0a43a", 2, 120)
				if e.hp <= 0:
					kill(e)
	if P.zt > 0:
		P.zt -= dt
		ZB.position = Vector3(P.x + cos(P.ang) * 240, 16, P.y + sin(P.ang) * 240)
		ZB.rotation.y = -P.ang
		if P.zt <= 0:
			ZB.visible = false
	if P.w.has("shield") and P.sh == 0:
		P.shT -= dt
		if P.shT <= 0:
			P.sh = 1
			sfx.tone(700, .15, "triangle", .08, 1100)
	for q in BX:
		q.x += q.vx * dt
		q.y += q.vy * dt
		q.l -= dt
		q.fl -= dt
	BX = keep(BX, func(q): return q.hp > 0 and q.l > 0 and Vector2(q.x - P.x, q.y - P.y).length() < 800)
	for i in WG.size():
		var w = WG[i]
		var a: float = P.ang
		var sd = 1 if i % 2 == 1 else -1
		var f = 1.0 + floor(i / 2) * .7
		var tx: float = P.x - cos(a) * 30 * f - sin(a) * 50 * sd * f
		var ty: float = P.y - sin(a) * 30 * f + cos(a) * 50 * sd * f
		w.l -= dt
		w.cd -= dt
		w.x += (tx - w.x) * minf(1.0, dt * 6)
		w.y += (ty - w.y) * minf(1.0, dt * 6)
		w.m.position = Vector3(w.x, absf(sin(t * 10 + i)) * 2, w.y)
		w.m.rotation.y = -a
		w.m.visible = not (w.l < 3 and int(floor(t * 8)) % 2 == 1)
		if fire and w.cd <= 0:
			var x: float = w.x + cos(a) * 10
			var y: float = w.y + sin(a) * 10
			if w.k == 0:
				w.cd = .9
				bl(x, y, a, 380, {"c": "#ff9f1c", "w": 16, "h": 8, "d": 8, "ex": 40.0, "edm": 2, "type": "wing"})
			elif w.k == 1:
				w.cd = .12
				bl(x, y, a, 820, {"c": "#ffd23f", "w": 12, "h": 4, "d": 4, "l": .5})
			else:
				w.cd = .3
				bl(x, y, a, 720, {"c": "#4aa3ff", "w": 24, "h": 8, "d": 8, "dmg": 2})
	WG = keep(WG, func(w): return w.l > 0)
	for c in CR:
		c.x += c.vx * dt
		c.y += c.vy * dt
		c.l -= dt
	CR = keep(CR, func(c): return c.l > 0)

# ---------------------------------------------------------------- enemies
func next_wave() -> void:
	wv += 1
	wa = randf() * TAU
	wq = []
	wt = .3
	if wv % 5 == 0:
		wq.append(3)
		for i in 2 + wv / 5:
			wq.append(0)
	else:
		var pos = wv % 5
		var c = wv / 5
		var n = mini(30, 4 + 2 * pos + 2 * c)
		var av = [0]
		if wv >= 2: av.append(1)
		if wv >= 3: av.append_array([4, 7])
		if wv >= 4: av.append_array([5, 2])
		if wv >= 6: av.append_array([6, 8])
		var M = 2 if wv < 3 else (3 if wv < 6 else (4 if wv < 20 else (5 if wv < 30 else 6)))
		var nt = 1 + randi() % mini(M, av.size())
		if pos == 1:
			nt = maxi(1, nt - 1)
		av.shuffle()
		var sub = av.slice(0, nt)
		for i in n:
			wq.append(sub[randi() % sub.size()])

func spawn(ty: int, a: float, X = null, Y = null) -> void:
	var d0 = ET[ty]
	var v = randi() % 6
	var da = a + PI + (randf() - .5) * .6
	var ex = P.x + cos(a) * SR if X == null else X
	var ey = P.y + sin(a) * SR if Y == null else Y
	var hp: float
	if ty == 3:
		hp = [95, 50, 70, 85, 75, 120][v] + (wv / 5.0 - 1.0) * 30.0
	else:
		hp = d0.hp + (int(wv / 3) if ty != 0 else 0)
	var m: Node3D
	match ty:
		0: m = Chars.inst("res://scenes/enemies/enemy_snake.tscn", d0.r * .8)
		4: m = Chars.inst("res://scenes/enemies/enemy_scorpion.tscn", d0.r * .7)
		5: m = Chars.inst("res://scenes/enemies/enemy_tnt.tscn", d0.r * .8)
		6: m = Chars.inst("res://scenes/enemies/enemy_gila.tscn", d0.r * .8)
		7: m = Chars.inst("res://scenes/enemies/enemy_weed.tscn", d0.r * .9)
		8: m = Chars.inst("res://scenes/enemies/enemy_sniper.tscn", d0.r * .8)
		3: m = Chars.inst("res://scenes/bosses/boss_%s.tscn" % Chars.BOSS_NAMES[v], d0.r * [.6, .5, .65, .55, .6, .62][v])
		_: m = Chars.inst("res://scenes/enemies/enemy_gator_%d.tscn" % ty, d0.r * .8)
	eid += 1
	E.append({"id": eid, "ty": ty, "x": ex, "y": ey, "hp": hp, "mhp": hp, "cd": 1 + randf(), "fl": 0.0, "a": 0.0, "n": 0, "dx": cos(da), "dy": sin(da), "v": v, "st": 0, "tm": 2.0, "dead": false, "by": "", "m": put(m, 0, 0, 0)})

func kill(e) -> void:
	if e.dead:
		return
	e.dead = true
	var d0 = ET[e.ty]
	var w: bool = e.by == "wand" and e.ty != 3
	if w:
		sfx.heart()
	else:
		sfx.boom(e.ty == 3)
	if e.ty == 5 and not w:
		for i in 8:
			ebul(e.x, e.y, i * .785, 210)
	score += d0.pts
	if w:
		critter(e)
	else:
		boom(e.x, e.y, d0.c, 14 + e.ty * 10, 260)
		shake = maxf(shake, 4 + e.ty * 4)
	var n = 14 if e.ty == 3 else (7 if e.ty == 2 else ((4 if e.ty == 6 else (3 if e.ty == 8 else 2)) if e.ty > 3 else e.ty + 1))
	for i in n:
		pk(e.x + (randf() - .5) * 40, e.y + (randf() - .5) * 40, 0)
	var r = 0.0 if e.ty == 3 else randf()
	if r < .04:
		pk(e.x, e.y, 1)
	elif r < .075:
		pk(e.x, e.y, 3)
	elif r < .085:
		pk(e.x, e.y, 4)
	if e.ty == 3:
		pk(e.x + 24, e.y, 3)
		shake = 26
		boom(e.x, e.y, "#ffd23f", 40, 420)

func mv(e, dx, dy, sp, dt) -> void:
	e.x += dx * sp * dt
	e.y += dy * sp * dt

func fan(e, n, sp, w) -> void:
	for i in n:
		ebul(e.x, e.y, e.a + (i - (n - 1) / 2.0) * w, sp)

func ring(e, n, sp, o) -> void:
	for i in n:
		ebul(e.x, e.y, o + i * TAU / n, sp)

func orb(e, sp, d, dist, ux, uy, dt) -> void:
	var o = -.6 if dist < d else (.8 if dist > d + 80 else 0.0)
	mv(e, -uy + ux * o, ux + uy * o, sp, dt)

func boss(e, dt, dist, ux, uy) -> void:
	var v: int = e.v
	e.tm -= dt
	match v:
		0:
			if e.st == 0:
				if dist > 240: mv(e, ux, uy, 70, dt)
				if e.tm <= 0: e.st = 1; e.tm = .7
			elif e.st == 1:
				e.fl = .05
				if e.tm <= 0: e.st = 2; e.tm = .9; e.dx = ux; e.dy = uy
			elif e.st == 2:
				mv(e, e.dx, e.dy, 540, dt)
				if e.tm <= 0: ring(e, 14, 200, t); shake = 12; e.st = 3; e.tm = 1.2
			elif e.tm <= 0:
				fan(e, 5, 250, .25); e.st = 0; e.tm = 1.3
		1:
			if e.st != 4: orb(e, 110, 380, dist, ux, uy, dt)
			if e.st == 0:
				if e.cd <= 0: ring(e, 2, 170, e.tm * 2.5); e.cd = .3
				if e.tm <= 0: e.st = 1; e.tm = .5
			elif e.st == 1:
				e.fl = .05
				if e.tm <= 0: fan(e, 5, 240, .24); e.st = 2; e.tm = .45
			elif e.st == 2:
				if e.tm <= 0: fan(e, 5, 220, .26); e.st = 3; e.tm = .5
			elif e.st == 3:
				e.fl = .05
				if e.tm <= 0: e.st = 4; e.tm = .6; e.dx = ux; e.dy = uy
			else:
				mv(e, e.dx, e.dy, 400, dt)
				if e.tm <= 0: e.st = 0; e.tm = 3.2
		2:
			orb(e, 190, 300, dist, ux, uy, dt)
			if e.st == 0:
				if e.cd <= 0: ebul(e.x, e.y, e.a + (randf() - .5) * .14, 340); e.cd = .2
				if e.tm <= 0:
					e.st = 1; e.tm = .9
					spawn(0, 0, e.x + 30, e.y)
					spawn(0, 0, e.x - 30, e.y)
					ring(e, 10, 230, t)
			elif e.tm <= 0:
				e.st = 0; e.tm = 2.2
		3:
			orb(e, 100, 330, dist, ux, uy, dt)
			if e.st == 0:
				if e.cd <= 0: ebul(e.x, e.y, e.a + sin(e.tm * 6) * .5, 240); e.cd = .1
				if e.tm <= 0: e.st = 1; e.tm = .5
			elif e.st == 1:
				e.fl = .05
				if e.tm <= 0: e.st = 2; e.tm = .5; e.dx = ux; e.dy = uy
			elif e.st == 2:
				mv(e, e.dx, e.dy, 560, dt)
				if e.tm <= 0:
					ring(e, 12, 190, t)
					spawn(0, 0, e.x, e.y)
					e.st = 3; e.tm = 1.2
			elif e.tm <= 0:
				e.st = 0; e.tm = 2.6
		4:
			orb(e, 150, 280, dist, ux, uy, dt)
			if e.st == 0:
				if e.cd <= 0: fan(e, 3, 330, .14); e.cd = .5
				if e.tm <= 0: e.st = 1; e.tm = .6
			elif e.st == 1:
				e.fl = .05
				if e.tm <= 0: ring(e, 16, 170, t); shake = 10; e.st = 2; e.tm = .45
			elif e.tm <= 0:
				ring(e, 16, 170, t + .2); e.st = 0; e.tm = 2.2
		_:
			if e.st == 0:
				if dist > 240: mv(e, ux, uy, 60, dt)
				if e.cd <= 0: fan(e, 5, 230, .3); e.cd = 1.1
				if e.tm <= 0: e.st = 1; e.tm = .8
			elif e.st == 1:
				e.fl = .05
				if e.tm <= 0:
					fan(e, 9, 280, .22)
					ring(e, 20, 170, t)
					shake = 14; e.st = 2; e.tm = 1.2
			elif e.tm <= 0:
				e.st = 0; e.tm = 2.6

# ---------------------------------------------------------------- main update
func upd(dt) -> void:
	t += dt
	var ax = float((1 if kd(KEY_D) else 0) - (1 if kd(KEY_A) else 0))
	var ay = float((1 if kd(KEY_S) else 0) - (1 if kd(KEY_W) else 0))
	if T.has("L"):
		var s = stick(T["L"])
		ax = s.x
		ay = s.y
	elif ax != 0 or ay != 0:
		var m = sqrt(ax * ax + ay * ay)
		ax /= m
		ay /= m
	var w = to_w(ax, ay)
	ax = w.x
	ay = w.y
	var k = minf(1.0, dt * 9)
	P.vx += (ax * 270 - P.vx) * k
	P.vy += (ay * 270 - P.vy) * k
	P.x += P.vx * dt
	P.y += P.vy * dt
	rock_push(P, 14)
	var fire = false
	var rx = (1 if kd(KEY_RIGHT) else 0) - (1 if kd(KEY_LEFT) else 0)
	var ry = (1 if kd(KEY_DOWN) else 0) - (1 if kd(KEY_UP) else 0)
	if T.has("R"):
		var s = stick(T["R"])
		if s.x != 0 or s.y != 0:
			var q = to_w(s.x, s.y)
			P.ang = atan2(q.y, q.x)
			fire = true
	elif rx != 0 or ry != 0:
		var q = to_w(rx, ry)
		P.ang = atan2(q.y, q.x)
		fire = true
	elif um:
		var h = mouse_world()
		if h != null:
			P.ang = atan2(h.z - P.y, h.x - P.x)
			if mdown:
				fire = true
	elif ax != 0 or ay != 0:
		P.ang = atan2(ay, ax)
	P.inv -= dt
	P.pw -= dt
	P.cool -= dt
	if fire and P.cool <= 0:
		P.cool = .13
		sfx.shoot()
		volley()
	wupd(dt, fire)
	wt -= dt
	if wq.size() > 0:
		if wt <= 0:
			spawn(wq.pop_front(), wa + (randf() - .5) * 1.3)
			wt = .2 + randf() * .15
	elif E.size() > 0:
		wr = 0
	elif wr == 0:
		wr = 1
		wt = 2.5
	elif wt <= 0:
		wr = 0
		next_wave()
	for b in B:
		bupd(b, dt)
	for b in EB:
		b.x += b.vx * dt
		b.y += b.vy * dt
		b.l -= dt
		if rock_hit(b.x, b.y):
			b.l = 0
			continue
		if Vector2(P.x - b.x, P.y - b.y).length() < 19:
			b.l = 0
			hurt()
			if S != "play":
				return
	for e in E:
		var d0 = ET[e.ty]
		var dx = P.x - e.x
		var dy = P.y - e.y
		var dist = maxf(sqrt(dx * dx + dy * dy), .001)
		var ux = dx / dist
		var uy = dy / dist
		e.a = atan2(dy, dx)
		var vx = ux
		var vy = uy
		var ww = 0.0
		var oo = 0.0
		if e.ty == 1 and dist < 260:
			vx = -ux * .4 - uy * .9
			vy = -uy * .4 + ux * .9
		elif e.ty == 3 and dist < 360:
			oo = -.5 if dist < 300 else 0.0
			vx = -uy * .7 + ux * oo
			vy = ux * .7 + uy * oo
		if e.ty == 0:
			ww = sin(t * 6 + e.x * .05) * .5
			vx -= uy * ww
			vy += ux * ww
		elif e.ty == 4:
			ww = sin(t * 9 + e.y * .05) * 1.1
			vx -= uy * ww
			vy += ux * ww
		elif e.ty == 8:
			oo = -1.0 if dist < 380 else (1.0 if dist > 470 else 0.0)
			vx = ux * oo - uy * .4
			vy = uy * oo + ux * .4
			if e.cd < .6:
				e.fl = .05
		if e.ty == 3:
			boss(e, dt, dist, ux, uy)
		elif e.ty == 7:
			e.x += e.dx * 270 * dt
			e.y += e.dy * 270 * dt
		else:
			var sp = d0.sp * (2.2 if dist > 420 else 1.0)
			e.x += vx * sp * dt
			e.y += vy * sp * dt
		if rock_push(e, d0.r * .7) and e.ty == 3 and e.v == 0 and e.st == 2:
			e.tm = 0
		e.fl -= dt
		e.cd -= dt
		if e.cd <= 0 and dist < SR * .8:
			if e.ty == 4:
				ebul(e.x, e.y, e.a, 300); e.cd = 2.2
			elif e.ty == 6:
				for i in range(-1, 2):
					ebul(e.x, e.y, e.a + i * .25, 200)
				e.cd = 2.4
			elif e.ty == 8:
				ebul(e.x, e.y, e.a, 520); e.cd = 2.6
		if e.ty > 0 and e.ty < 3 and e.cd <= 0 and dist < SR * .8:
			if e.ty == 1:
				ebul(e.x, e.y, e.a, 270)
				e.cd = 1.8 - minf(.8, t / 150)
			elif e.ty == 2:
				for i in 8:
					ebul(e.x, e.y, i * .785 + t, 190)
				e.cd = 2.6
		if dist < d0.r + 16:
			if e.ty == 0 or e.ty == 5 or e.ty == 7:
				e.hp = 0
				kill(e)
			hurt()
			if S != "play":
				return
	for b in B:
		for e in E:
			if not b.d and e.hp > 0 and not b.hs.has(e.id) and Vector2(b.x - e.x, b.y - e.y).length() < ET[e.ty].r + 8:
				hit_e(b, e)
	for p in PK:
		p.l -= dt
		var dx = P.x - p.x
		var dy = P.y - p.y
		var d = maxf(sqrt(dx * dx + dy * dy), .001)
		if p.k == 0 and d < 170:
			p.x += dx / d * 420 * dt
			p.y += dy / d * 420 * dt
		if d < 32:
			p.l = 0
			if p.k == 0:
				coins += 1
				bank += 1
				score += 2
				sfx.coin()
			elif p.k == 1:
				P.hp = mini(MAXHP, P.hp + 1)
				sfx.heart()
			elif p.k == 3:
				grant_gun()
				sfx.pow_up()
			else:
				grant_wing()
				sfx.heart()
	parts(dt)
	B = keep(B, func(b): return b.l > 0 and not b.d)
	EB = keep(EB, func(b): return b.l > 0)
	E = keep(E, func(e): return e.hp > 0 and Vector2(e.x - P.x, e.y - P.y).length() < SR * 1.6)
	PK = keep(PK, func(p): return p.l > 0)
	shake = 0.0 if shake < .1 else shake * .88

func parts(dt) -> void:
	for p in PT:
		p.x += p.vx * dt
		p.y += p.vy * dt
		p.h += p.vh * dt
		p.vh -= 220 * dt
		p.vx *= .96
		p.vy *= .96
		p.l -= dt
	PT = keep(PT, func(p): return p.l > 0)

# ---------------------------------------------------------------- render sync
func sync() -> void:
	carousel()
	if S == "play" and not P.is_empty():
		PM = CHM[chi]
		PM.position = Vector3(P.x, 0, P.y)
		PM.scale = Vector3.ONE * PM.get_meta("bs")
		PM.rotation.y = -P.ang
		var sp = minf(1.0, Vector2(P.vx, P.vy).length() / 200.0)
		PM.get_meta("inner").position.y = absf(sin(t * 12)) * BOUNCE_PLAYER * sp / PM.get_meta("bs")
		PM.get_meta("tail").rotation.y = sin(t * 9) * .4
	for e in E:
		var m: Node3D = e.m
		m.position = Vector3(e.x, 0, e.y)
		m.rotation.y = -e.a
		var f = 1.25 if e.fl > 0 else 1.0
		m.scale = Vector3(f, f, f) * m.get_meta("bs")
		if m.has_meta("segs"):
			var segs = m.get_meta("segs")
			var s = m.get_meta("s")
			for i in segs.size():
				segs[i].position.z = sin(t * 12 - i * .9) * .3 * s
		else:
			m.get_meta("inner").position.y = absf(sin(t * 9 + e.x * .02)) * BOUNCE_ENEMY / m.get_meta("bs")
		if m.has_meta("wings"):
			var ws = m.get_meta("wings")
			for i in ws.size():
				ws[i].rotation.x = (-1 if i == 1 else 1) * (.5 + sin(t * 8) * .5)
		m.get_meta("tail").rotation.y = sin(t * 10 + e.y * .02) * .5
		if m.has_meta("spin"):
			var sn = m.get_meta("spin")
			sn.rotation.z = t * 7
			sn.rotation.x = t * 4
	for b in B:
		b.m.position = Vector3(b.x, 16, b.y)
	for b in EB:
		b.m.position = Vector3(b.x, 16, b.y)
	for p in PK:
		p.m.position = Vector3(p.x, 22 + sin(t * 6 + p.x) * 3, p.y)
		p.m.rotation.y = t * 3
		p.m.visible = not (p.l < 3 and int(floor(t * 10)) % 2 == 1)
	for p in PT:
		p.m.position = Vector3(p.x, maxf(1.0, p.h), p.y)
		var sc = maxf(.01, p.s * p.l / p.L)
		p.m.scale = Vector3(sc, sc, sc)
	var sx = (randf() - .5) * shake
	var sz = (randf() - .5) * shake
	var hy = 30.0 if pmOpen else 0.0
	var zoom = 1.5 if pmOpen else 1.0
	camera.size = (2.0 * hw if W < H else 2.0 * hg) / zoom
	camera.position = Vector3(cam.x + 600 + sx, 690 + hy, cam.y + 600 + sz)
	camera.look_at(Vector3(cam.x + sx, hy, cam.y + sz), Vector3.UP)
	GR.position = Vector3(cam.x, 0, cam.y)
	terrain()
	wsync()

func wsync() -> void:
	var pl = S == "play" and not P.is_empty()
	SHD.visible = pl and P.w.has("shield") and P.sh > 0
	if SHD.visible:
		SHD.position = Vector3(P.x, 18, P.y)
	SAW.visible = pl and P.sawOn
	if SAW.visible:
		SAW.position = Vector3(P.x + cos(P.ang) * 40, 14, P.y + sin(P.ang) * 40)
		SAW.rotation.y = t * 30
	if not pl:
		ZB.visible = false
	for q in BX:
		q.m.position = Vector3(q.x, 14 + sin(t * 2 + q.x) * 3, q.y)
		q.m.rotation.y = t
		var f = 1.15 if q.fl > 0 else 1.0
		q.m.scale = Vector3(f, f, f)
	for c in CR:
		c.m.position = Vector3(c.x, absf(sin(c.l * 12)) * 8, c.y)

# ---------------------------------------------------------------- prize machine (shop)
func _build_machine() -> void:
	MR = Chars.inst("res://scenes/shop/prize_machine.tscn")
	MR.position = Vector3(-25, 0, 25)
	MR.visible = false
	add_child(MR)
	MG = MR.get_node("Machine")
	CRK = MG.get_node("Crank")
	for c in MG.get_children():
		if c.name.begins_with("Capsule"):
			c.set_meta("y", c.position.y)
			c.set_meta("p", randf() * 6)
			CAPS.append(c)

func loc(x, z) -> Vector2:
	return Vector2(x - 25, z + 25)

func pz_reset() -> void:
	pz.st = "idle"
	pz.t = 0.0
	if pz.cap != null:
		pz.cap.queue_free()
		pz.cap = null
	if pz.hv != null:
		pz.hv.visible = false
		pz.hv = null
	for e in EX:
		e.m.queue_free()
	EX.clear()

func boom_rb(x, z) -> void:
	var w = loc(x, z)
	for k in 90:
		var a = randf() * TAU
		var b = randf() * PI - 1.2
		var v = 140 + randf() * 220
		var s = 5 + randf() * 8
		var m = Chars.bx(s, s, s, RB[k % 7])
		m.position = Vector3(w.x, 18, w.y)
		add_child(m)
		EX.append({"m": m, "vx": cos(a) * cos(b) * v, "vy": sin(b) * v + 120, "vz": sin(a) * cos(b) * v, "l": 1.5, "L": 1.5, "s": s})
	for k in 28:
		var a = k / 28.0 * TAU
		var m = Chars.bx(10, 10, 10, RB[k % 7])
		m.position = Vector3(w.x, 18, w.y)
		add_child(m)
		EX.append({"m": m, "vx": cos(a) * 300, "vy": 40.0, "vz": sin(a) * 300, "l": 1.2, "L": 1.2, "s": 10.0})

func pz_upd(dt) -> void:
	pz.t += dt
	var T_: float = pz.t
	var st: String = pz.st
	for c in CAPS:
		var yy: float = c.get_meta("y")
		var pp: float = c.get_meta("p")
		c.position.y = yy + (sin(ck * 45 + pp) * 2 if st == "turn" else sin(ck * 2 + pp) * .3)
	MG.position = Vector3(sin(T_ * 55) * 1.5 if st == "turn" else 0.0, 0, 0)
	if st == "turn":
		CRK.rotation.x = T_ * 10
		if int(floor(T_ * 9)) != int(floor((T_ - dt) * 9)):
			sfx.clack()
	if st == "turn" and T_ > 1.4:
		pz.st = "drop"
		pz.t = 0.0
		pz.cap = Chars.inst("res://scenes/shop/capsule_%d.tscn" % pz.col, 28.0)
		MR.add_child(pz.cap)
		pz.cap.position = Vector3(36, 20, 12)
	elif st == "drop":
		var u = minf(1.0, T_ / .9)
		var c: Node3D = pz.cap
		c.position = Vector3(36 + 62 * u, 14 + 8 * (1 - u) + 32 * sin(PI * u), 12)
		c.rotation.z = -u * 5
		c.rotation.x = u * 2
		if u >= 1.0:
			pz.st = "wait"
			pz.t = 0.0
			sfx.thunk()
			c.rotation = Vector3.ZERO
			pr_l.text = ""
			show_btns(["op"])
	elif st == "wait":
		var c: Node3D = pz.cap
		c.rotation.z = sin(T_ * 6) * .12
		c.position.y = 14 + absf(sin(T_ * 3)) * 3
	elif st == "shake":
		var c: Node3D = pz.cap
		var k = 1.0 + T_ * .5
		c.scale = Vector3(k, k, k) * 28.0
		c.rotation.z = sin(T_ * 70) * .3
		if T_ > .55:
			pz.st = "show"
			pz.t = 0.0
			var p = c.position
			boom_rb(p.x, p.z)
			var i = 1 + randi() % (CHN.size() - 1)
			var dup = UN.has(i)
			if dup:
				bank += 100
			else:
				UN[i] = true
				Chars.silhouette(CHM[i], false)
			save()
			chi = i
			pick(0)
			sfx.rainbow(dup)
			var w = loc(p.x, p.z)
			var h: Node3D = CHM[i]
			h.position = Vector3(w.x, 0, w.y)
			h.rotation.y = -.785
			h.scale = Vector3(.01, .01, .01)
			h.visible = true
			pz.hv = h
			c.queue_free()
			pz.cap = null
			pr_l.text = ("%s  +100 coins" % CHN[i]) if dup else CHN[i]
			show_btns(["ok"])
			busy = false
			pr_ui()
			flash.color.a = .9
			create_tween().tween_property(flash, "color:a", 0.0, .6)
	elif st == "show" and pz.hv != null:
		var h: Node3D = pz.hv
		var k = minf(1.0, T_ / .5)
		var sc = 2.4 * (1 - pow(1 - k, 3)) * (1 + .15 * sin(k * 3.14))
		h.scale = Vector3(sc, sc, sc) * h.get_meta("bs")
		h.get_meta("inner").position.y = absf(sin(ck * 5)) * BOUNCE_MENU / h.get_meta("bs")
		h.get_meta("tail").rotation.y = sin(ck * 6) * .4
	for e in EX:
		e.m.position += Vector3(e.vx, e.vy, e.vz) * dt
		e.vy -= 420 * dt
		e.vx *= .985
		e.vz *= .985
		e.m.rotation.x += dt * 6
		e.m.rotation.y += dt * 5
		e.l -= dt
		var kk = maxf(.01, e.l / e.L)
		e.m.scale = Vector3(e.s * kk, e.s * kk, e.s * kk)
		if e.m.position.y < 2:
			e.m.position.y = 2
			e.vy = absf(e.vy) * .4
	for i in range(EX.size() - 1, -1, -1):
		if EX[i].l <= 0:
			EX[i].m.queue_free()
			EX.remove_at(i)

func fmt(ms: float) -> String:
	var s = int(ceil(ms / 1000.0))
	return "%d:%02d:%02d" % [s / 3600, (s % 3600) / 60, s % 60]

func now_ms() -> float:
	return Time.get_unix_time_from_system() * 1000.0

func pr_ui() -> void:
	var left = CHN.size() - UN.size()
	var fl = maxf(0.0, FREE_MS - (now_ms() - lastFree))
	bk_l.text = "COINS  %d" % bank
	bk3_l.text = "COINS  %d" % bank
	b_sp.disabled = busy or left <= 0 or bank < COST
	b_fr.disabled = busy or left <= 0 or fl > 0
	b_fr.text = ("FREE " + fmt(fl)) if fl > 0 else "FREE GIFT"
	if left <= 0 and not busy and pr_l.text == "":
		pr_l.text = "ALL UNLOCKED!"

func open_shop() -> void:
	pmOpen = true
	set_menu(false)
	pm.visible = true
	for m in CHM:
		m.visible = false
	pz_reset()
	MR.visible = true
	show_btns(["sp", "fr", "bk2"])
	pr_l.text = ""
	pr_ui()

func shop_back() -> void:
	if busy:
		return
	pz_reset()
	MR.visible = false
	pmOpen = false
	pm.visible = false
	set_menu(true)
	pick(0)

func shop_ok() -> void:
	pz_reset()
	show_btns(["sp", "fr", "bk2"])
	pr_l.text = ""
	pr_ui()

func spin(free: bool) -> void:
	if busy or CHN.size() - UN.size() < 1 or pz.st != "idle":
		return
	if free:
		if now_ms() - lastFree < FREE_MS:
			return
		lastFree = now_ms()
	else:
		if bank < COST:
			return
		bank -= COST
	busy = true
	save()
	show_btns([])
	pr_l.text = ""
	pz.col = randi() % 7
	pz.st = "turn"
	pz.t = 0.0
	pr_ui()

func open_cap() -> void:
	if pz.st != "wait":
		return
	show_btns([])
	sfx.whine()
	pz.st = "shake"
	pz.t = 0.0

# ---------------------------------------------------------------- loop
func _process(delta: float) -> void:
	var dt = minf(.05, delta)
	ck += dt
	if pmOpen:
		pz_upd(dt)
	if S == "play":
		upd(dt)
		cam.x += (P.x - cam.x) * minf(1.0, dt * 8)
		cam.y += (P.y - cam.y) * minf(1.0, dt * 8)
	else:
		if S == "menu":
			cam.x = 0.0 if pmOpen else 100.0
			cam.y = cam.x
		else:
			parts(dt)
		shake *= .9
	sync()
	hud.queue_redraw()
