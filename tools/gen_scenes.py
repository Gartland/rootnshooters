"""Generates every .tscn / .tres in the project. Run from anywhere:  python3 tools/gen_scenes.py"""
import os, sys, math, random, zlib
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from shim import *
import builders as B
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

SPECIAL = {
    '@shadow': dict(color=(.353, .227, .078, .3), unshaded=True),
    '@glass':  dict(color=(.75, .91, 1.0, .28), unshaded=False),
    '@shield': dict(color=(.5, .89, 1.0, .35), unshaded=False)}

def fnum(v):
    s = ('%.5f' % v).rstrip('0').rstrip('.')
    return '0' if s in ('', '-0') else s

def mat_path(col):
    name = 'm_' + col.lstrip('#') if not col.startswith('@') else col[1:]
    path = f'{ROOT}/materials/{name}.tres'
    if not os.path.exists(path):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        if col.startswith('@'):
            sp = SPECIAL[col]; c = sp['color']
            txt = ('[gd_resource type="StandardMaterial3D" format=3]\n\n[resource]\ntransparency = 1\n'
                   + ('shading_mode = 0\n' if sp['unshaded'] else '')
                   + 'depth_draw_mode = 2\nalbedo_color = Color(%s, %s, %s, %s)\nroughness = 1.0\n' % tuple(fnum(v) for v in c))
        else:
            h = col.lstrip('#'); c = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
            txt = ('[gd_resource type="StandardMaterial3D" format=3]\n\n[resource]\nalbedo_color = Color(%s, %s, %s, 1)\n'
                   'roughness = 1.0\nmetallic_specular = 0.0\n' % tuple(fnum(v) for v in c))
        open(path, 'w').write(txt)
    return 'res://materials/' + name + '.tres'

def basis(n):
    x, y, z = n.rotation.x, n.rotation.y, n.rotation.z
    cx, sx, cy, sy, cz, sz = math.cos(x), math.sin(x), math.cos(y), math.sin(y), math.cos(z), math.sin(z)
    Rx = [[1, 0, 0], [0, cx, -sx], [0, sx, cx]]; Ry = [[cy, 0, sy], [0, 1, 0], [-sy, 0, cy]]; Rz = [[cz, -sz, 0], [sz, cz, 0], [0, 0, 1]]
    mm = lambda A, Bm: [[sum(A[i][k] * Bm[k][j] for k in range(3)) for j in range(3)] for i in range(3)]
    R = mm(mm(Ry, Rx), Rz); S = [n.scale.x, n.scale.y, n.scale.z]
    return [[R[i][j] * S[j] for j in range(3)] for i in range(3)]

def emit(root, rel):
    root.name = os.path.splitext(os.path.basename(rel))[0]
    ext, ext_lines, subs, sub_lines, nodes = {}, [], {}, [], []
    def ext_res(typ, path):
        if (typ, path) not in ext:
            ext[(typ, path)] = '%d_%05d' % (len(ext) + 1, zlib.crc32(path.encode()) % 100000)
            ext_lines.append(f'[ext_resource type="{typ}" path="{path}" id="{ext[(typ, path)]}"]')
        return ext[(typ, path)]
    def sub(n):
        kind, dims, col = n.mesh
        key = (kind, dims, col)
        if key not in subs:
            mid = ext_res('StandardMaterial3D', mat_path(col))
            sid = f'{"BoxMesh" if kind == "box" else "PlaneMesh"}_{len(subs) + 1}'
            if kind == 'box':
                sz = 'Vector3(%s, %s, %s)' % tuple(fnum(v) for v in dims)
                sub_lines.append(f'[sub_resource type="BoxMesh" id="{sid}"]\nmaterial = ExtResource("{mid}")\nsize = {sz}\n')
            else:
                sub_lines.append(f'[sub_resource type="PlaneMesh" id="{sid}"]\nmaterial = ExtResource("{mid}")\nsize = Vector2({fnum(dims[0])}, {fnum(dims[1])})\n')
            subs[key] = sid
        return subs[key]
    def walk(n, ppath, is_root):
        head = f'[node name="{n.name}"'
        if n.type and not n.instance: head += f' type="{n.type}"'
        if not is_root: head += f' parent="{ppath}"'
        if n.groups: head += ' groups=[' + ', '.join(f'"{g}"' for g in n.groups) + ']'
        if n.instance: head += f' instance=ExtResource("{ext_res("PackedScene", n.instance)}")'
        head += ']'
        props = []
        b = basis(n); p = n.position
        ident = all(abs(b[i][j] - (1 if i == j else 0)) < 1e-9 for i in range(3) for j in range(3))
        if not (ident and abs(p.x) + abs(p.y) + abs(p.z) < 1e-9):
            props.append('transform = Transform3D(' + ', '.join(fnum(b[i][j]) for i in range(3) for j in range(3)) + ', %s, %s, %s)' % (fnum(p.x), fnum(p.y), fnum(p.z)))
        if n.mesh: props.append(f'mesh = SubResource("{sub(n)}")')
        nodes.append(head + ('\n' + '\n'.join(props) if props else '') + '\n')
        cpath = '.' if is_root else (n.name if ppath == '.' else ppath + '/' + n.name)
        for c in n.children: walk(c, cpath, False)
    walk(root, '', True)
    out = f'{ROOT}/{rel}'
    os.makedirs(os.path.dirname(out), exist_ok=True)
    steps = len(ext_lines) + len(sub_lines) + 1
    open(out, 'w').write(f'[gd_scene load_steps={steps} format=3]\n\n' + '\n'.join(ext_lines) + ('\n\n' if ext_lines else '') + '\n'.join(sub_lines) + '\n' + '\n'.join(nodes))

def box(parent, w, h, d, col, x=0, y=0, z=0, name=None):
    m = bx(w, h, d, col); m.position = V3(x, y, z)
    if name: m.name = name
    parent.add_child(m); return m

def inst(parent, path, x=0, y=0, z=0, name=None, scale=1.0, roty=0.0):
    n = Node(None, name, instance=path); n.position = V3(x, y, z); n.scale = V3(scale, scale, scale); n.rotation.y = roty
    parent.add_child(n); return n

# ---------------------------------------------------------------- common
sh = bx(3.2, .02, 1.8, '@shadow'); sh.position = V3(.3, .13, 0); sh.groups = ['shadow']
emit(sh, 'scenes/common/shadow.tscn')

# ---------------------------------------------------------------- characters / enemies / bosses / wingmen
PLAYERS = [lambda: B.gator(1, '#3ddc6e', '#8b5a2b', '#ffd23f', True), lambda: B.arma(1), lambda: B.plat(1), lambda: B.frog(1), lambda: B.mole(1),
           lambda: B.rainfrog(1), lambda: B.possum(1), lambda: B.jim(1), lambda: B.coon(1), lambda: B.jack(1), lambda: B.dog(1),
           lambda: B.toad(1), lambda: B.skunk(1), lambda: B.runner(1), lambda: B.tort(1)]
for i, f in enumerate(PLAYERS): emit(f(), 'scenes/characters/char_%02d.tscn' % i)
emit(B.snake(1), 'scenes/enemies/enemy_snake.tscn')
emit(B.scorpion(1), 'scenes/enemies/enemy_scorpion.tscn')
emit(B.tnt(1), 'scenes/enemies/enemy_tnt.tscn')
emit(B.gila(1), 'scenes/enemies/enemy_gila.tscn')
emit(B.weed(1), 'scenes/enemies/enemy_weed.tscn')
emit(B.sniper(1), 'scenes/enemies/enemy_sniper.tscn')
emit(B.gator(1, '#4f7a3a', '#c9a66b', '#222222', False), 'scenes/enemies/enemy_gator_1.tscn')
emit(B.gator(1, '#2f5d3a', '#111111', '#ffd23f', False), 'scenes/enemies/enemy_gator_2.tscn')
for name, f in [('bison', B.bison), ('vulture', B.vulture), ('coyote', B.coyote), ('rattler', B.rattler), ('scorpion', B.scorpion), ('bear', B.bear)]:
    emit(f(1), f'scenes/bosses/boss_{name}.tscn')
for k in range(3): emit(B.wing(k), f'scenes/wingmen/wingman_{k}.tscn')

# ---------------------------------------------------------------- pickups & supply boxes (nested bars scene)
for nm, col in [('white', '#ffffff'), ('yellow', '#ffd23f')]:
    r = Node('Node3D'); box(r, 14, 4, 4, col, name='BarX'); box(r, 4, 4, 14, col, name='BarZ')
    emit(r, f'scenes/pickups/pickup_bars_{nm}.tscn')
r = Node('Node3D'); box(r, 15, 15, 5, '#ffd23f', name='Body'); emit(r, 'scenes/pickups/pickup_coin.tscn')
for nm, col, bars in [('heart', '#ff4d6d', 'white'), ('gun', '#4aa3ff', 'yellow'), ('wingman', '#ff9f1c', 'yellow')]:
    r = Node('Node3D'); box(r, 22, 22, 22, col, name='Cube')
    inst(r, f'res://scenes/pickups/pickup_bars_{bars}.tscn', 0, 12, 0, 'Bars'); emit(r, f'scenes/pickups/pickup_{nm}.tscn')
for nm, c, d in [('blue', '#2e86de', '#4aa3ff'), ('orange', '#e8820c', '#ffb347')]:
    r = Node('Node3D'); box(r, 28, 18, 20, c, 0, 9, 0, 'Base'); box(r, 30, 8, 22, d, 0, 22, 0, 'Lid'); box(r, 6, 8, 3, '#ffd23f', 0, 18, 11.5, 'Latch')
    emit(r, f'scenes/pickups/box_{nm}.tscn')
for i, k in enumerate(['#a67c3d', '#c9c9d0', '#8b5a2b', '#ffffff']):
    r = Node('Node3D'); box(r, 9, 8, 12, k, name='Body'); box(r, 4, 7, 4, k, 0, 7, -2, 'Head'); emit(r, f'scenes/critters/critter_{i}.tscn')

# ---------------------------------------------------------------- effects
emit(bx(46, 46, 46, '@shield'), 'scenes/effects/shield_bubble.tscn')
emit(bx(420, 12, 24, '#bff7ff'), 'scenes/effects/zap_beam.tscn')
r = Node('Node3D'); box(r, 28, 6, 28, '#c8c8d0', name='Disc'); box(r, 34, 5, 8, '#e0a43a', name='BladeX'); box(r, 8, 5, 34, '#e0a43a', name='BladeZ')
emit(r, 'scenes/effects/saw.tscn')

# ---------------------------------------------------------------- environment (nested: tile -> cactus)
g = Node('MeshInstance3D'); g.mesh = ('plane', (6000, 6000), '#e6c27e'); emit(g, 'scenes/environment/ground.tscn')
r = Node('Node3D')
for q in [[10, 44, 10, 0, 22, 0], [14, 7, 7, -10, 24, 0], [7, 16, 8, -16, 31, 0], [14, 7, 7, 10, 18, 0], [7, 14, 8, 16, 25, 0]]:
    box(r, q[0], q[1], q[2], '#3f8f4a', q[3], q[4], q[5])
emit(r, 'scenes/environment/cactus.tscn')
r = Node('Node3D')
box(r, 1, 1, 1, '#d9a95f', name='Patch'); box(r, 1, 1, 1, '#9a8f84', name='Rock'); box(r, 1, 1, 1, '#b3a89c', name='Rock2')
inst(r, 'res://scenes/environment/cactus.tscn', name='Cactus'); emit(r, 'scenes/environment/terrain_tile.tscn')

# ---------------------------------------------------------------- shop (nested: machine -> capsules)
RB = ['#ff3b3b', '#ff9f1c', '#ffe14d', '#3ddc6e', '#2e86de', '#5b4bff', '#b05ce6']
for i, c in enumerate(RB):
    r = Node('Node3D'); box(r, 1, .5, 1, '#ffffff', 0, .25, 0, 'Top'); box(r, 1, .5, 1, c, 0, -.25, 0, 'Bottom'); emit(r, f'scenes/shop/capsule_{i}.tscn')
root = Node('Node3D')
M = Node('Node3D', 'Machine'); root.add_child(M)
box(M, 90, 46, 80, '#e63946', 0, 23, 0); box(M, 94, 8, 84, '#a82733', 0, 4, 0); box(M, 92, 6, 82, '#ff6b78', 0, 49, 0)
box(M, 88, 12, 78, '#8b5a2b', 0, 135, 0); box(M, 22, 10, 22, '#ffd23f', 0, 146, 0)
for x in (-38, 38):
    for z in (-33, 33): box(M, 6, 80, 6, '#8b5a2b', x, 90, z)
box(M, 8, 24, 32, '#222222', 40, 22, 12); box(M, 4, 26, 26, '#f2c14e', 42, 34, -22); box(M, 8, 8, 8, '#a67c3d', 44, 34, -22)
cr = Node('Node3D', 'Crank'); cr.position = V3(48, 34, -22); M.add_child(cr)
box(cr, 5, 4, 20, '#ffd23f', name='Arm'); box(cr, 8, 8, 8, '#fff3b0', 0, 0, 10, 'Knob')
s = box(M, 104, .3, 94, '@shadow', 0, 1.5, 0, 'Shadow'); s.groups = ['shadow']
random.seed(3); n = 0
for y in (59, 75, 91):
    for x in (-27, -9, 9, 27):
        for z in (-20, 0, 20):
            if random.random() < .8:
                inst(M, f'res://scenes/shop/capsule_{random.randrange(7)}.tscn', x + (random.random() - .5) * 4, y, z + (random.random() - .5) * 4, f'Capsule{n}', 15.0, random.random() * 3); n += 1
box(M, 80, 78, 70, '@glass', 0, 90, 0, 'Glass')
emit(root, 'scenes/shop/prize_machine.tscn')
print('scenes generated')
