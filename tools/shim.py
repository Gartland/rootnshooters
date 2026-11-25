"""Tiny scene-graph shim so the character builders (converted from GDScript) can emit .tscn files."""
import math

class V3:
    def __init__(s, x=0, y=0, z=0): s.x, s.y, s.z = x, y, z

def Vector3(x=0, y=0, z=0): return V3(x, y, z)

class Node:
    def __init__(s, type='Node3D', name=None, instance=None):
        s.type, s.name, s.instance = type, name, instance
        s.position, s.rotation, s.scale = V3(), V3(), V3(1, 1, 1)
        s.children, s.parent, s.mesh, s.groups, s.meta, s._n = [], None, None, [], {}, 0
    def add_child(s, c):
        c.parent = s
        if c.name is None:
            base = 'Box' if c.type == 'MeshInstance3D' else ('Inst' if c.instance else 'Part')
            s._n += 1
            c.name = f'{base}{s._n}'
        s.children.append(c)
    def set_meta(s, k, v):
        s.meta[k] = v
        if k == 'segs':
            for i, n in enumerate(v): n.name = f'Seg{i}'
        elif k == 'wings':
            for i, n in enumerate(v): n.name = f'Wing{i}'
        elif k == 'spin':
            v.name = 'Spin'
    def get_meta(s, k):
        if k == 'inner': return [c for c in s.children if c.name == 'Inner'][0]
        return s.meta[k]

_bj = [0]
def reset_bj(): _bj[0] = 0

def bx(w, h, d, c):
    k = 1 + ((_bj[0] * .6180339887) % 1) * .012
    _bj[0] += 1
    n = Node('MeshInstance3D')
    n.mesh = ('box', (w * k, h * k, d * k), c)
    return n

def ad(p, s, w, h, d, col, x, y, z):
    m = bx(w * s, h * s, d * s, col)
    m.position = V3(x * s, y * s, z * s)
    p.add_child(m)
    return m

def _rgb(h): h = h.lstrip('#'); return [int(h[i:i + 2], 16) for i in (0, 2, 4)]
def dk(c): return '#%02x%02x%02x' % tuple(int(v * .7) for v in _rgb(c))
def lerp_white(c, t): return '#%02x%02x%02x' % tuple(int(v + (255 - v) * t) for v in _rgb(c))

def eye(p, s, ax, dr, x, y, z, sz):
    t = .07; e = dr * (t / 2 - .015); f = dr * (t / 2 + .02); X = ax == 'x'
    ad(p, s, t if X else sz, sz, sz if X else t, '#ffffff', x + (e if X else 0), y, z + (0 if X else e))
    q = sz * .8
    ad(p, s, .05 if X else q, q, q if X else .05, '#111111', x + (f if X else 0), y, z + (0 if X else f))

def eyeF(p, s, x, y, z, sz): eye(p, s, 'x', 1, x, y, z, sz); eye(p, s, 'x', 1, x, y, -z, sz)
def eyeS(p, s, x, y, z, sz): eye(p, s, 'z', 1, x, y, z, sz); eye(p, s, 'z', -1, x, y, -z, sz)

class Rig:
    def __init__(s, sc):
        reset_bj()
        s.s = sc
        s.gp, s.inn, s.tl = Node('Node3D', 'Root'), Node('Node3D', 'Inner'), Node('Node3D', 'Tail')
        s.gp.add_child(s.inn)
        s.tl.position = V3(-.7 * sc, .7 * sc, 0)
        s.inn.add_child(s.tl)
        s.gp.add_child(Node(None, 'Shadow', instance='res://scenes/common/shadow.tscn'))
    def add(s, p, w, h, d, col, x, y, z): return ad(p, s.s, w, h, d, col, x, y, z)
    def base(s, c):
        s.add(s.inn, .35, .5, .35, dk(c), -.1, .25, .28)
        s.add(s.inn, .35, .5, .35, dk(c), -.1, .25, -.28)
        s.add(s.inn, 1.1, .8, 1, c, -.2, .9, 0)
        s.add(s.inn, .7, .25, .2, '#222222', 1, 1, .55)
    def eyes(s, x, y, z): eyeF(s.inn, s.s, x, y, z, .26)
    def axe(s):
        pg = Node('Node3D')
        pg.position = V3(-.4 * s.s, 1.5 * s.s, -.35 * s.s)
        pg.rotation.z = .5
        s.inn.add_child(pg)
        s.add(pg, .1, 1.6, .1, '#6b4a2b', 0, 0, 0)
        s.add(pg, .15, .15, .9, '#9aa0a6', 0, .8, 0)
