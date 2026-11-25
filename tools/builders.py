from shim import *

def gator(s, c, hat, band, pl):
	r = Rig(s)
	inn = r.inn
	sn = lerp_white(c, .25)
	d = dk(c)
	r.add(inn, .35, .5, .35, d, -.1, .25, .28)
	r.add(inn, .35, .5, .35, d, -.1, .25, -.28)
	r.add(inn, 1, .8, .9, c, -.2, .9, 0)
	r.add(r.tl, .9, .35, .4, c, -.45, 0, 0)
	r.add(inn, 1.25, 1.1, 1.25, c, .45, 1.85, 0)
	r.add(inn, 1.5, .7, 1.05, sn, 1.35, 1.65, 0)
	r.add(inn, .15, .15, .12, "#ffffff", 2.08, 1.28, .4)
	r.add(inn, .15, .15, .12, "#ffffff", 2.08, 1.28, -.4)
	eyeS(inn, s, .85, 2.12, .625, .32)
	k = .8 if pl else 1.0
	r.add(inn, 1.85 * k, .15, 1.85 * k, hat, .45, 2.46, 0)
	r.add(inn, .85 * k, .7 * k, .85 * k, hat, .45, 2.52 + .35 * k, 0)
	r.add(inn, .89 * k, .18, .89 * k, band, .45, 2.6, 0)
	r.add(inn, .4, .3, 1, "#e63946" if pl else band, .35, 1.3, 0)
	if pl:
		r.add(inn, .7, .25, .2, "#222222", 1, 1, .55)
		r.add(inn, .2, .2, .2, "#ffd23f", -.2, 1.1, .5)
	return r.gp

def arma(s):
	r = Rig(s)
	r.base("#b9a897")
	for i in range(3):
		r.add(r.inn, .28, .18, 1.08, "#8a7a6a", -.55 + i * .35, 1.33, 0)
	r.add(r.tl, .9, .2, .2, "#8a7a6a", -.45, 0, 0)
	r.add(r.inn, .95, .85, .95, "#b9a897", .55, 1.75, 0)
	r.add(r.inn, .9, .45, .5, "#d9c7b5", 1.35, 1.6, 0)
	r.add(r.inn, .2, .4, .2, "#8a7a6a", .3, 2, .58)
	r.add(r.inn, .2, .4, .2, "#8a7a6a", .3, 2, -.58)
	r.eyes(1.025, 2, .3)
	r.add(r.inn, 1.36, .12, 1.36, "#d8c08a", .4, 2.3, 0)
	r.add(r.inn, .68, .396, .68, "#d8c08a", .4, 2.623, 0)
	r.add(r.inn, .712, .14, .712, "#6b4a2b", .4, 2.47, 0)
	r.add(r.inn, .25, .25, .1, "#ffd23f", .1, 1, .52)
	return r.gp

def plat(s):
	r = Rig(s)
	r.base("#7a5a3a")
	r.add(r.tl, .9, .15, .8, "#5c4329", -.5, 0, 0)
	r.add(r.inn, 1, .8, 1.05, "#7a5a3a", .5, 1.75, 0)
	r.add(r.inn, 1.1, .18, 1, "#e0a458", 1.35, 1.55, 0)
	r.add(r.inn, .9, .15, .9, "#c98a3c", 1.3, 1.68, 0)
	r.eyes(1, 2, .32)
	r.add(r.inn, 1.52, .1, 1.52, "#a67c52", .4, 2.3, 0)
	r.add(r.inn, .68, .352, .68, "#a67c52", .4, 2.526, 0)
	r.add(r.inn, .712, .12, .712, "#4a3320", .4, 2.43, 0)
	r.axe()
	return r.gp

def frog(s):
	r = Rig(s)
	r.base("#4caf50")
	r.add(r.inn, 1.14, .52, 1.04, "#3a6fb0", -.2, .74, 0)
	r.add(r.inn, .55, .4, .3, "#3b8f40", -.5, .26, .45)
	r.add(r.inn, .55, .4, .3, "#3b8f40", -.5, .26, -.45)
	r.add(r.tl, .3, .2, .3, "#4caf50", -.2, 0, 0)
	r.add(r.inn, 1.1, .8, 1.4, "#4caf50", .5, 1.7, 0)
	r.add(r.inn, .4, .22, 1.25, "#a5d6a7", 1.1, 1.45, 0)
	for z in [.42, -.42]:
		r.add(r.inn, .42, .42, .42, "#4caf50", .95, 2.3, z)
		eye(r.inn, s, "x", 1, 1.16, 2.3, z, .32)
	return r.gp

def mole(s):
	r = Rig(s)
	r.base("#4a4048")
	r.add(r.tl, .5, .15, .15, "#ff9aa8", -.3, 0, 0)
	r.add(r.inn, .5, .4, .3, "#ff9aa8", .75, .7, .65)
	r.add(r.inn, .5, .4, .3, "#ff9aa8", .75, .7, -.65)
	r.add(r.inn, 1, .85, 1, "#4a4048", .5, 1.75, 0)
	r.add(r.inn, .8, .5, .6, "#5c505a", 1.3, 1.6, 0)
	r.add(r.inn, .4, .46, .46, "#ff9aa8", 1.8, 1.65, 0)
	r.eyes(1, 2, .3)
	r.add(r.inn, 1.2, .1, 1.2, "#ffd23f", .4, 2.3, 0)
	r.add(r.inn, .76, .44, .76, "#ffd23f", .4, 2.55, 0)
	r.add(r.inn, .3, .25, .3, "#fff6a8", .82, 2.55, 0)
	r.axe()
	return r.gp

def rainfrog(s):
	r = Rig(s)
	for z in [.5, -.5]:
		for x in [.5, -.6]:
			r.add(r.inn, .4, .35, .4, "#8f5f33", x, .18, z)
	r.add(r.inn, 1.5, 1.2, 1.5, "#b9814a", -.1, .95, 0)
	r.add(r.inn, .7, .25, .2, "#222222", .9, .95, .5)
	r.add(r.inn, 1.1, .75, 1.4, "#b9814a", .6, 1.8, 0)
	r.add(r.inn, .1, .15, 1.1, "#5a3a1c", 1.18, 1.6, 0)
	r.eyes(1.15, 2, .4)
	r.add(r.inn, 1.44, .12, 1.44, "#ffd23f", .5, 2.3, 0)
	r.add(r.inn, .72, .44, .72, "#ffd23f", .5, 2.59, 0)
	return r.gp

def possum(s):
	r = Rig(s)
	r.base("#9aa0a8")
	r.add(r.tl, 1.3, .2, .2, "#f0a0b0", -.65, 0, 0)
	r.add(r.inn, .95, .85, .95, "#ece8e8", .55, 1.75, 0)
	r.add(r.inn, .8, .4, .5, "#f4eeee", 1.25, 1.6, 0)
	r.add(r.inn, .18, .18, .22, "#ff8fa3", 1.68, 1.65, 0)
	r.eyes(1.025, 2, .28)
	for z in [.58, -.58]:
		r.add(r.inn, .3, .3, .15, "#444444", .35, 2.05, z)
	r.add(r.inn, 1.28, .1, 1.28, "#8b6b4a", .45, 2.3, 0)
	r.add(r.inn, .68, .396, .68, "#8b6b4a", .45, 2.553, 0)
	r.add(r.inn, .712, .12, .712, "#ffd23f", .45, 2.43, 0)
	return r.gp

def jim(s):
	r = Rig(s)
	for z in [.22, -.22]:
		r.add(r.inn, .3, .6, .3, "#3a6fb0", -.1, .3, z)
		r.add(r.inn, .4, .2, .34, "#5a3a1c", 0, .11, z)
	r.add(r.inn, .9, .9, .7, "#d9534f", -.1, 1.05, 0)
	r.add(r.inn, .95, .6, .75, "#3a6fb0", -.1, .8, 0)
	r.add(r.inn, .95, .9, .9, "#f1c27d", .1, 1.95, 0)
	r.eyes(.575, 2, .22)
	r.add(r.inn, .1, .12, .1, "#e0a070", .6, 1.8, 0)
	r.add(r.inn, .7, .25, .18, "#222222", .55, 1.1, .45)
	r.add(r.inn, 1.6, .12, 1.6, "#c9a66b", .1, 2.52, 0)
	r.add(r.inn, .8, .528, .8, "#c9a66b", .1, 2.864, 0)
	r.add(r.inn, .832, .14, .832, "#e63946", .1, 2.68, 0)
	return r.gp

def coon(s):
	r = Rig(s)
	r.base("#8d8d96")
	r.add(r.tl, .9, .35, .35, "#8d8d96", -.45, 0, 0)
	r.add(r.tl, .14, .37, .37, "#2b2b33", -.3, 0, 0)
	r.add(r.tl, .14, .37, .37, "#2b2b33", -.65, 0, 0)
	r.add(r.inn, .95, .85, 1, "#8d8d96", .55, 1.75, 0)
	r.add(r.inn, .5, .4, .5, "#d8d8de", 1.25, 1.6, 0)
	r.add(r.inn, .15, .15, .2, "#111111", 1.52, 1.65, 0)
	r.add(r.inn, .07, .3, 1.02, "#222222", 1.03, 2, 0)
	r.eyes(1.06, 2, .28)
	for z in [.56, -.56]:
		r.add(r.inn, .25, .3, .15, "#555555", .35, 2.1, z)
	r.add(r.inn, 1.2, .1, 1.2, "#6b4a2b", .4, 2.32, 0)
	r.add(r.inn, .68, .396, .68, "#6b4a2b", .4, 2.573, 0)
	r.add(r.inn, .712, .12, .712, "#e63946", .4, 2.45, 0)
	return r.gp

def jack(s):
	r = Rig(s)
	r.base("#c9a27a")
	r.add(r.tl, .35, .35, .35, "#ffffff", -.2, 0, 0)
	r.add(r.inn, .9, .8, .9, "#c9a27a", .55, 1.75, 0)
	r.add(r.inn, .4, .3, .6, "#e8d0b0", 1.15, 1.6, 0)
	r.add(r.inn, .15, .15, .2, "#ff8fa3", 1.38, 1.65, 0)
	r.eyes(1, 1.95, .28)
	for z in [.22, -.22]:
		r.add(r.inn, .2, 1, .22, "#c9a27a", .22, 2.65, z)
		r.add(r.inn, .1, .8, .12, "#f0a0b0", .26, 2.65, z)
	for z in [.38, -.38]:
		r.add(r.inn, .1, .5, .1, "#8b5a2b", .75, 2.4, z)
		r.add(r.inn, .12, .1, .3, "#8b5a2b", .75, 2.7, z * 1.4)
	r.add(r.inn, .4, .3, 1, "#e63946", .8, 1.3, 0)
	return r.gp

def dog(s):
	r = Rig(s)
	r.base("#c9a06a")
	r.add(r.inn, .1, .6, .7, "#f1e0c0", .36, .95, 0)
	r.add(r.tl, .4, .2, .2, "#a77d4a", -.2, 0, 0)
	r.add(r.inn, 1, .9, 1, "#c9a06a", .55, 1.8, 0)
	r.add(r.inn, .4, .35, .55, "#e8d0b0", 1.2, 1.6, 0)
	r.add(r.inn, .15, .15, .2, "#111111", 1.42, 1.68, 0)
	r.add(r.inn, .08, .2, .14, "#ffffff", 1.42, 1.4, .08)
	r.add(r.inn, .08, .2, .14, "#ffffff", 1.42, 1.4, -.08)
	r.eyes(1.05, 2.05, .3)
	r.add(r.inn, 1.36, .1, 1.36, "#a67c52", .5, 2.4, 0)
	r.add(r.inn, .72, .44, .72, "#a67c52", .5, 2.67, 0)
	r.add(r.inn, .752, .12, .752, "#ffd23f", .5, 2.52, 0)
	return r.gp

def toad(s):
	r = Rig(s)
	r.base("#9c7a4a")
	r.add(r.inn, 1.4, .3, 1.3, "#b8935a", -.2, 1.4, 0)
	r.add(r.tl, .6, .2, .25, "#7d6038", -.3, 0, 0)
	for x in [-.5, -.1, .3]:
		for z in [.4, -.4]:
			r.add(r.inn, .2, .25, .2, "#6b5030", x, 1.65, z)
	r.add(r.inn, 1.1, .7, 1.3, "#9c7a4a", .55, 1.7, 0)
	r.eyes(1.1, 1.9, .4)
	for z in [.78, -.78]:
		r.add(r.inn, .2, .5, .2, "#6b5030", .1, 2, z)
	r.add(r.inn, 1.04, .1, 1.04, "#8b5a2b", .55, 2.1, 0)
	r.add(r.inn, .56, .352, .56, "#8b5a2b", .55, 2.326, 0)
	r.add(r.inn, .592, .12, .592, "#ffd23f", .55, 2.22, 0)
	return r.gp

def skunk(s):
	r = Rig(s)
	r.base("#2b2b33")
	r.add(r.inn, 1.12, .3, .3, "#ffffff", -.2, 1.33, 0)
	r.add(r.tl, .5, 1.1, .7, "#2b2b33", -.2, .5, 0)
	r.add(r.tl, .52, .5, .3, "#ffffff", -.2, .7, 0)
	r.add(r.inn, .95, .85, 1, "#2b2b33", .55, 1.75, 0)
	r.add(r.inn, .9, .1, .2, "#ffffff", .55, 2.2, 0)
	r.add(r.inn, .4, .35, .5, "#e0d0d0", 1.2, 1.6, 0)
	r.add(r.inn, .15, .15, .2, "#ff8fa3", 1.42, 1.65, 0)
	r.eyes(1.025, 2, .3)
	r.add(r.inn, 1.28, .1, 1.28, "#c0392b", .4, 2.32, 0)
	r.add(r.inn, .68, .396, .68, "#c0392b", .4, 2.573, 0)
	r.add(r.inn, .712, .12, .712, "#ffd23f", .4, 2.45, 0)
	return r.gp

def runner(s):
	r = Rig(s)
	for z in [.22, -.22]:
		r.add(r.inn, .2, 1.1, .2, "#e0a43a", -.1, .55, z)
	r.add(r.inn, 1.3, .8, .7, "#4a6fa5", -.2, 1.5, 0)
	r.add(r.tl, 1.3, .2, .5, "#2a3a55", -.6, 0, 0)
	r.add(r.inn, .4, .9, .4, "#4a6fa5", .5, 2.2, 0)
	r.add(r.inn, .6, .5, .5, "#4a6fa5", .7, 2.8, 0)
	r.add(r.inn, .7, .15, .25, "#e08a2e", 1.3, 2.75, 0)
	eyeS(r.inn, s, .8, 2.85, .25, .22)
	for x in [.3, .5, .7]:
		r.add(r.inn, .15, .4, .15, "#2a3a55", x, 3.2, 0)
	r.add(r.inn, .5, .3, .5, "#e63946", .5, 2.55, 0)
	r.add(r.inn, .6, .2, .2, "#222222", .8, 1.4, .45)
	return r.gp

def tort(s):
	r = Rig(s)
	for x in [.5, -.7]:
		for z in [.55, -.55]:
			r.add(r.inn, .45, .4, .45, "#8a9a5b", x, .2, z)
	r.add(r.inn, 1.8, .5, 1.5, "#6b8e3a", -.1, .65, 0)
	r.add(r.inn, 1.4, .4, 1.2, "#7aa043", -.1, 1.1, 0)
	r.add(r.inn, .9, .3, .9, "#88b04b", -.1, 1.45, 0)
	r.add(r.tl, .4, .2, .25, "#8a9a5b", -.2, 0, 0)
	r.add(r.inn, .7, .6, .6, "#8a9a5b", 1.2, .9, 0)
	r.eyes(1.55, 1, .17)
	r.add(r.inn, 1.04, .1, 1.04, "#8b5a2b", 1.2, 1.28, 0)
	r.add(r.inn, .52, .352, .52, "#8b5a2b", 1.2, 1.476, 0)
	r.add(r.inn, .552, .12, .552, "#ffd23f", 1.2, 1.38, 0)
	r.add(r.inn, .6, .2, .2, "#222222", .8, .8, .7)
	return r.gp

def tnt(s):
	g = dog(s)
	inn = g.get_meta("inner")
	for z in [-.3, 0, .3]:
		ad(inn, s, .25, .8, .25, "#e63946", -.5, 1.5, z)
	ad(inn, s, .1, .4, .1, "#222222", -.5, 2.1, 0)
	ad(inn, s, .2, .2, .2, "#ffd23f", -.5, 2.4, 0)
	return g

def gila(s):
	r = Rig(s)
	for x in [.6, -.6]:
		for z in [.55, -.55]:
			r.add(r.inn, .35, .4, .35, "#7a3a1d", x, .2, z)
	r.add(r.inn, 2.2, .6, 1, "#e8a33d", -.1, .7, 0)
	for x in [-.7, -.1, .5]:
		r.add(r.inn, .3, .62, 1.02, "#2b2b33", x, .7, 0)
	r.add(r.tl, 1.2, .35, .5, "#e8a33d", -.6, 0, 0)
	r.add(r.inn, 1, .55, 1, "#2b2b33", 1.4, .8, 0)
	eyeS(r.inn, s, 1.5, .95, .5, .22)
	r.add(r.inn, 1.3, .1, 1.3, "#8b5a2b", 1.4, 1.12, 0)
	r.add(r.inn, .65, .35, .65, "#8b5a2b", 1.4, 1.32, 0)
	return r.gp

def weed(s):
	r = Rig(s)
	bl = Node('Node3D')
	bl.position = Vector3(0, .8 * s, 0)
	r.inn.add_child(bl)
	for q in [[0, 0, 0], [1.6, 0, 0], [0, 1.6, 0], [0, 0, 1.6], [1.6, 1.6, 0], [0, 1.6, 1.6]]:
		m = bx(1.6 * s, .22 * s, .22 * s, "#a67c3d")
		m.rotation = Vector3(q[0], q[1], q[2])
		bl.add_child(m)
	r.gp.set_meta("spin", bl)
	return r.gp

def sniper(s):
	g = gator(s, "#3b6e4a", "#222222", "#e63946", False)
	inn = g.get_meta("inner")
	ad(inn, s, 2.2, .15, .15, "#222222", 1.5, 1.15, .55)
	ad(inn, s, .3, .2, .2, "#555555", 1.3, 1.3, .55)
	return g

def snake(s):
	r = Rig(s)
	segs = []
	for i in range(7):
		segs.append(r.add(r.inn, .55, .4, .55, "#5b3d1b" if i % 2 else "#a67c3d", -.1 - i * .5, .25, 0))
	r.add(r.inn, .9, .55, .7, "#a67c3d", .5, .4, 0)
	eyeS(r.inn, s, .8, .5, .35, .2)
	for z in [.2, -.2]:
		r.add(r.inn, .08, .25, .08, "#ffffff", .92, .12, z)
	r.add(r.inn, .5, .08, .1, "#ff2e63", 1.15, .25, 0)
	r.add(r.inn, .15, .1, .4, "#ff2e63", 1.45, .25, 0)
	r.tl.position = Vector3(-3.6 * s, .3 * s, 0)
	r.add(r.tl, .3, .3, .3, "#e8d9a8", 0, 0, 0)
	r.add(r.tl, .25, .25, .25, "#d8c590", -.3, 0, 0)
	r.add(r.tl, .2, .2, .2, "#e8d9a8", -.55, 0, 0)
	r.gp.set_meta("segs", segs)
	r.gp.set_meta("s", s)
	return r.gp

def scorpion(s):
	r = Rig(s)
	c = "#a8532a"
	d = "#7a3a1d"
	for x in [.5, .1, -.3, -.7]:
		for z in [.6, -.6]:
			r.add(r.inn, .15, .35, .5, d, x, .18, z)
	r.add(r.inn, 2, .7, 1.4, c, 0, .65, 0)
	r.add(r.inn, .7, .55, .9, c, 1.3, .7, 0)
	for z in [.8, -.8]:
		r.add(r.inn, .9, .25, .3, c, 1.5, .55, z)
		r.add(r.inn, .45, .35, .35, d, 2.05, .62, z * .9)
	eyeF(r.inn, s, 1.65, .85, .25, .2)
	r.add(r.inn, .5, .5, .5, c, -1.1, .95, 0)
	r.add(r.inn, .45, .6, .45, c, -1.5, 1.45, 0)
	r.add(r.inn, .45, .45, .45, c, -1.3, 1.95, 0)
	r.add(r.inn, .4, .4, .4, c, -.8, 2.2, 0)
	r.add(r.inn, .3, .3, .45, "#e63946", -.35, 2.1, 0)
	r.add(r.inn, 1.1, .1, 1.1, "#222222", 1.3, 1.05, 0)
	r.add(r.inn, .55, .35, .55, "#222222", 1.3, 1.3, 0)
	return r.gp

def bear(s):
	r = Rig(s)
	c = "#6b4423"
	d = "#4a2e18"
	for x in [.6, -.8]:
		for z in [.55, -.55]:
			r.add(r.inn, .55, .9, .55, d, x, .45, z)
	r.add(r.inn, 1.8, 1.4, 1.6, c, -.1, 1.55, 0)
	r.add(r.tl, .4, .4, .4, d, -.2, 0, 0)
	r.add(r.inn, 1.2, 1.1, 1.2, c, 1.1, 2, 0)
	r.add(r.inn, .6, .5, .7, "#c9a27a", 1.7, 1.8, 0)
	r.add(r.inn, .2, .2, .2, "#111111", 2.05, 1.9, 0)
	for z in [.65, -.65]:
		r.add(r.inn, .35, .35, .3, d, .95, 2.35, z)
	eyeF(r.inn, s, 1.7, 2.25, .3, .26)
	r.add(r.inn, .4, .35, 1.3, "#e63946", .85, 1.5, 0)
	r.add(r.inn, .9, .9, .9, "#8b5a2b", -.7, 2.65, 0)
	r.add(r.inn, .3, .3, .3, "#ffd23f", -.5, 3.2, .2)
	r.add(r.inn, .3, .3, .3, "#ffd23f", -.8, 3.2, -.2)
	r.add(r.inn, 1.9, .12, 1.9, "#111111", 1, 2.62, 0)
	r.add(r.inn, .9, .55, .9, "#111111", 1, 2.95, 0)
	r.add(r.inn, .94, .14, .94, "#ffd23f", 1, 2.75, 0)
	return r.gp

def bison(s):
	r = Rig(s)
	for x in [.6, -.9]:
		for z in [.5, -.5]:
			r.add(r.inn, .45, .9, .45, "#3d2616", x, .45, z)
	r.add(r.inn, 2, 1.2, 1.5, "#5a3a22", -.2, 1.5, 0)
	r.add(r.inn, 1, .7, 1.4, "#3d2616", -.4, 2.3, 0)
	r.add(r.tl, .25, .8, .25, "#3d2616", -.1, -.3, 0)
	r.add(r.inn, 1.2, 1.1, 1.3, "#3d2616", 1.25, 1.4, 0)
	r.add(r.inn, .6, .7, 1.1, "#2b1a0f", 1.5, .7, 0)
	for z in [.8, -.8]:
		r.add(r.inn, .2, .2, .6, "#f1e6c8", 1, 2.05, z * .95)
		r.add(r.inn, .2, .6, .2, "#f1e6c8", 1, 2.4, z * 1.22)
	eyeF(r.inn, s, 1.85, 1.7, .35, .24)
	r.add(r.inn, .2, .2, .3, "#ffd23f", 1.85, .6, 0)
	r.add(r.inn, .5, .3, 1.4, "#e63946", .85, 1, 0)
	r.add(r.inn, 1.2, .1, 1.1, "#222222", 1.1, 2, 0)
	r.add(r.inn, .7, .45, .7, "#222222", 1.1, 2.27, 0)
	r.add(r.inn, .74, .12, .74, "#ffd23f", 1.1, 2.12, 0)
	return r.gp

def vulture(s):
	r = Rig(s)
	wings = []
	for z in [.25, -.25]:
		r.add(r.inn, .25, 1, .25, "#e0a43a", 0, .5, z)
	r.add(r.inn, 1, 1.2, .9, "#2a2a2a", -.1, 1.6, 0)
	r.add(r.tl, .8, .2, .7, "#1c1c1c", -.4, 0, 0)
	r.add(r.inn, 1.1, .3, 1.1, "#f5f5f5", .35, 2.3, 0)
	r.add(r.inn, .4, .8, .4, "#e8a0a0", .52, 2.7, 0)
	r.add(r.inn, .7, .6, .6, "#e8a0a0", .65, 3.3, 0)
	r.add(r.inn, .7, .18, .3, "#e0a43a", 1.2, 3.2, 0)
	r.add(r.inn, .25, .3, .25, "#e0a43a", 1.5, 3.1, 0)
	eyeF(r.inn, s, 1, 3.42, .2, .2)
	for z in [1, -1]:
		wg = Node('Node3D')
		wg.position = Vector3(-.1 * s, 1.9 * s, z * .5 * s)
		r.inn.add_child(wg)
		r.add(wg, .9, .2, 1.8, "#1c1c1c", 0, 0, z * .9)
		r.add(wg, .5, .2, 1.1, "#3a3a3a", -.4, 0, z * 1.9)
		wings.append(wg)
	r.add(r.inn, 1.2, .1, 1.2, "#111111", .65, 3.65, 0)
	r.add(r.inn, .6, .45, .6, "#111111", .65, 3.9, 0)
	r.add(r.inn, .64, .1, .64, "#c0392b", .65, 3.75, 0)
	r.gp.set_meta("wings", wings)
	return r.gp

def coyote(s):
	r = Rig(s)
	for x in [.7, -.7]:
		for z in [.3, -.3]:
			r.add(r.inn, .25, 1, .25, "#a97c43", x, .5, z)
	r.add(r.inn, 1.6, .8, .8, "#c89b5c", 0, 1.3, 0)
	r.add(r.inn, .9, .5, .7, "#f0dcb4", .1, 1, 0)
	r.add(r.tl, .9, .45, .45, "#c89b5c", -.45, 0, 0)
	r.add(r.tl, .3, .45, .45, "#3a2a1a", -1, 0, 0)
	r.add(r.inn, .9, .8, .8, "#c89b5c", 1.1, 1.9, 0)
	r.add(r.inn, .9, .4, .45, "#d9b57e", 1.8, 1.75, 0)
	r.add(r.inn, .2, .2, .2, "#111111", 2.3, 1.85, 0)
	for z in [.55, -.55]:
		r.add(r.inn, .2, .55, .25, "#a97c43", .7, 2.6, z)
	eyeF(r.inn, s, 1.55, 2.1, .27, .22)
	r.add(r.inn, .4, .3, .9, "#2e86de", .8, 1.5, 0)
	for z in [.5, -.5]:
		r.add(r.inn, .6, .2, .2, "#222222", .6, 1.2, z)
	r.add(r.inn, 1.5, .1, 1.5, "#9c6b3a", .95, 2.35, 0)
	r.add(r.inn, .7, .5, .7, "#9c6b3a", .95, 2.65, 0)
	r.add(r.inn, .74, .12, .74, "#f2d16b", .95, 2.5, 0)
	return r.gp

def rattler(s):
	r = Rig(s)
	segs = []
	for i in range(8):
		segs.append(r.add(r.inn, 1, .8, 1, "#5b3d1b" if i % 2 else "#a67c3d", -.2 - i * .7, .45, 0))
	r.add(r.inn, 1.2, .9, 1.1, "#a67c3d", .6, .8, 0)
	eyeS(r.inn, s, .9, 1.05, .55, .3)
	for z in [.3, -.3]:
		r.add(r.inn, .1, .35, .1, "#ffffff", 1.15, .4, z)
	r.add(r.inn, .6, .1, .12, "#ff2e63", 1.5, .5, 0)
	r.add(r.inn, .15, .1, .4, "#ff2e63", 1.85, .5, 0)
	r.add(r.inn, 1.9, .12, 1.9, "#222222", .5, 1.4, 0)
	r.add(r.inn, .9, .5, .9, "#222222", .5, 1.7, 0)
	r.add(r.inn, .94, .14, .94, "#ffd23f", .5, 1.5, 0)
	r.tl.position = Vector3(-5.5 * s, .5 * s, 0)
	r.add(r.tl, .4, .4, .4, "#e8d9a8", 0, 0, 0)
	r.add(r.tl, .35, .35, .35, "#d8c590", -.4, 0, 0)
	r.add(r.tl, .3, .3, .3, "#e8d9a8", -.75, 0, 0)
	r.gp.set_meta("segs", segs)
	r.gp.set_meta("s", s)
	return r.gp

def wing(k):
	reset_bj()
	g = Node('Node3D')
	c = ["#d9b88f", "#ff9f1c", "#8a9aa8"][k]
	ad(g, 1, .9, .8, 1, c, 0, .5, 0)
	ad(g, 1, .8, .7, .8, c, .35, 1.1, 0)
	if k == 0:
		ad(g, 1, .3, .3, .5, "#333333", .8, 1, 0)
		ad(g, 1, .9, .3, .3, "#556b2f", -.2, 1.1, 0)
	if k == 1:
		for z in [.25, -.25]:
			ad(g, 1, .2, .3, .2, c, .3, 1.6, z)
	if k == 2:
		ad(g, 1, .1, .5, .1, "#888888", .3, 1.6, 0)
		ad(g, 1, .2, .2, .2, "#ff4d6d", .3, 1.9, 0)
	eyeF(g, 1, .75, 1.15, .22, .22)
	ad(g, 1, .6, .2, .2, "#222222", .6, .6, .5)
	return g
