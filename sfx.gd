extends Node
# Procedural sound effects (port of the WebAudio synth). Each tone/noise is rendered to a short WAV buffer.

const RATE = 16000
const SC = [0, 2, 4, 7, 9, 12, 14, 16, 19, 21, 24]
var pool: Array = []
var idx = 0
var muted = false
var hc = 0
var hT = 0.0
var cc = 0
var cT = 0.0
var lastEx = -1
var exT = 0.0
var esT = 0.0
var lT = 0.0

func _ready() -> void:
	for i in 24:
		var p = AudioStreamPlayer.new()
		p.volume_db = -6.0
		add_child(p)
		pool.append(p)

func now() -> float:
	return Time.get_ticks_msec() / 1000.0

func semi(f: float, n: int) -> float:
	return f * pow(2.0, SC[min(n, SC.size() - 1)] / 12.0)

func _wave(type: String, ph: float) -> float:
	var f = fmod(ph, 1.0)
	match type:
		"square": return 1.0 if f < .5 else -1.0
		"triangle": return 4.0 * absf(f - .5) - 1.0
		"sawtooth": return 2.0 * f - 1.0
	return sin(ph * TAU)

func _emit(data: PackedByteArray) -> void:
	if muted:
		return
	var w = AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.stereo = false
	w.data = data
	var p: AudioStreamPlayer = pool[idx]
	idx = (idx + 1) % pool.size()
	p.stream = w
	p.play()

func tone(f: float, d: float, type: String, vol: float, f2: float = 0.0, when: float = 0.0) -> void:
	if muted:
		return
	var off = int(when * RATE)
	var n = int(d * RATE)
	var buf = PackedByteArray()
	buf.resize((off + n + 300) * 2)
	var ph = 0.0
	for i in n:
		var t = float(i) / RATE
		var fr = f
		if f2 > 0.0:
			fr = f * pow(f2 / f, t / d)
		ph += fr / RATE
		var g = vol * pow(.001 / vol, t / d)
		buf.encode_s16((off + i) * 2, int(clampf(_wave(type, ph) * g * 0.6, -1.0, 1.0) * 32767.0))
	_emit(buf)

func noise(d: float, vol: float, f1: float, f2: float, type: String = "lowpass", when: float = 0.0) -> void:
	if muted:
		return
	var off = int(when * RATE)
	var n = int(d * RATE)
	var buf = PackedByteArray()
	buf.resize((off + n + 300) * 2)
	var lp = 0.0
	var lp2 = 0.0
	for i in n:
		var t = float(i) / RATE
		var fc = f1 * pow(f2 / f1, t / d)
		var a = 1.0 - exp(-TAU * minf(fc, 7000.0) / RATE)
		var x = randf() * 2.0 - 1.0
		var y = 0.0
		if type == "highpass":
			lp += a * (x - lp)
			y = x - lp
		elif type == "bandpass":
			lp += a * (x - lp)
			lp2 += (a * .5) * (lp - lp2)
			y = lp - lp2
		else:
			lp += a * (x - lp)
			y = lp
		var g = vol * pow(.001 / vol, t / d)
		buf.encode_s16((off + i) * 2, int(clampf(y * g * 0.9, -1.0, 1.0) * 32767.0))
	_emit(buf)

func shoot() -> void: tone(700 * (.95 + randf() * .1), .06, "square", .05, 260)

func hit() -> void:
	var n = now()
	if n - hT > .6: hc = 0
	hT = n
	var f = semi(520, hc)
	hc += 1
	noise(.03, .08, 4000, 1800, "highpass")
	tone(f, .07, "square", .11, f * .85)

func boom(big: bool) -> void:
	var n = now()
	if n - exT < .04 and not big: return
	exT = n
	var v = randi() % 4
	while v == lastEx: v = randi() % 4
	lastEx = v
	var k = 1.6 if big else 1.0
	if v == 0:
		noise(.28 * k, .35, 2200, 250); tone(140, .2 * k, "sine", .3, 45)
	elif v == 1:
		noise(.5 * k, .4, 1500, 120); tone(90, .45 * k, "sine", .5, 30)
	elif v == 2:
		for i in 4: noise(.07, .25, 3500 - i * 500, 600, "bandpass", i * .06)
		noise(.3 * k, .25, 900, 150); tone(110, .25, "triangle", .25, 40)
	else:
		noise(.35 * k, .35, 3000, 200); tone(320, .3 * k, "sawtooth", .12, 50); tone(70, .4 * k, "sine", .35, 28)
	if big:
		noise(.9, .45, 1200, 90); tone(60, .9, "sine", .6, 25)

func hurt() -> void:
	hc = 0
	noise(.2, .3, 900, 150); tone(220, .3, "sawtooth", .2, 70)

func es() -> void:
	if now() - esT < .1: return
	esT = now()
	tone(300, .12, "square", .04, 120)

func coin() -> void:
	var n = now()
	if n - cT > .5: cc = 0
	cT = n
	var f = semi(880, cc)
	cc += 1
	tone(f, .09, "square", .07)
	tone(f * 1.5, .12, "square", .06, 0, .06)

func heart() -> void:
	tone(660, .12, "triangle", .15); tone(880, .12, "triangle", .15, 0, .07); tone(1320, .2, "triangle", .15, 0, .14)

func pow_up() -> void: tone(300, .3, "square", .1, 1200)

func over() -> void:
	tone(440, .5, "triangle", .25, 110); tone(330, .7, "triangle", .2, 80, .2)

func clack() -> void:
	noise(.03, .15, 4000, 1500, "highpass"); tone(1200, .02, "square", .04)

func thunk() -> void:
	tone(120, .15, "sine", .4, 50); noise(.1, .2, 800, 200)

func whine() -> void: tone(300, .55, "sawtooth", .08, 1500)

func rainbow(dup: bool) -> void:
	boom(true)
	if dup:
		tone(300, .4, "triangle", .15, 150, .1)
		return
	for i in 10: tone(semi(660, i), .2, "triangle", .1, 0, .05 * i)
	for f in [523, 659, 784]: tone(f, .6, "sine", .12, 0, .5)

func launch() -> void:
	if now() - lT < .08: return
	lT = now()
	tone(260 + randf() * 60, .1, "triangle", .05, 520)

func blip(f1: float, f2: float) -> void: tone(f1, .06, "square", .08, f2)
