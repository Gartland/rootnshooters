"""Generates ui/theme.tres and the UI scenes (scenes/ui/*.tscn). Run: python3 tools/gen_ui.py
Afterwards you can edit them freely in the Godot editor (regenerating overwrites your edits)."""
import os, math
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def S(s): return '"' + s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n') + '"'
def C(h, a=1.0):
    h = h.lstrip('#'); r, g, b = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    return 'Color(%.4f, %.4f, %.4f, %s)' % (r, g, b, a)
def V2(x, y): return f'Vector2({x}, {y})'
def dark(h, k):
    h = h.lstrip('#'); return '#%02x%02x%02x' % tuple(int(int(h[i:i + 2], 16) * k) for i in (0, 2, 4))

# ------------------------------------------------------------------ theme
def stylebox(sid, bg, border=None, shadow=False, panel=False):
    L = [f'[sub_resource type="StyleBoxFlat" id="{sid}"]', f'bg_color = {bg}']
    for c in ('top_left', 'top_right', 'bottom_left', 'bottom_right'): L.append(f'corner_radius_{c} = 6')
    if border:
        L += ['border_width_bottom = 5', f'border_color = {border}']
    if panel:
        L += ['content_margin_left = 22.0', 'content_margin_top = 12.0', 'content_margin_right = 22.0', 'content_margin_bottom = 16.0',
              'shadow_color = Color(0.35, 0.23, 0.08, 0.35)', 'shadow_size = 5', 'shadow_offset = Vector2(0, 5)']
    else:
        L += ['content_margin_left = 14.0', 'content_margin_top = 8.0', 'content_margin_right = 14.0', 'content_margin_bottom = 8.0']
    return '\n'.join(L) + '\n'

subs, props = [], []
def button_set(prefix, base):
    for st, k in (('normal', 1), ('hover', 1), ('pressed', .85), ('disabled', .7)):
        sid = f'{prefix}_{st}'
        subs.append(stylebox(sid, C(dark(base, k)), C(dark(base, k * .65))))
        props.append(f'{prefix}/styles/{st} = SubResource("{sid}")')
subs.append(stylebox('panel', 'Color(1, 1, 1, 0.92)', panel=True))
props += ['default_font_size = 20', 'Button/colors/font_color = Color(1, 1, 1, 1)', 'Button/colors/font_hover_color = Color(1, 1, 1, 1)',
          'Button/colors/font_pressed_color = Color(1, 1, 1, 1)', 'Button/colors/font_disabled_color = Color(1, 1, 1, 0.5)',
          'Button/font_sizes/font_size = 20', 'PanelContainer/styles/panel = SubResource("panel")',
          'Label/colors/font_color = ' + C('#16324f'), 'Label/font_sizes/font_size = 20']
button_set('Button', '#ff5a5f')
props.append('SecondaryButton/base_type = &"Button"'); button_set('SecondaryButton', '#5a6b7d')
def label_var(name, size, color, outline=None, outline_size=0):
    props.extend([f'{name}/base_type = &"Label"', f'{name}/font_sizes/font_size = {size}', f'{name}/colors/font_color = {color}'])
    if outline: props.extend([f'{name}/colors/font_outline_color = {outline}', f'{name}/constants/outline_size = {outline_size}'])
label_var('TitleLabel', 44, C('#ffd23f'), C('#24140a'), 14)
label_var('ScoreLabel', 28, C('#ffffff'), C('#06284d'), 6)
label_var('BossLabel', 16, C('#ffffff'), C('#24140a'), 6)
label_var('SmallLabel', 11, C('#16324f'))
label_var('DotsLabel', 12, C('#16324f'))
label_var('OverTitle', 28, C('#ff7b7b'))
subs.append(stylebox('boss_bg', C('#24140a')) .replace('content_margin_left = 14.0', 'content_margin_left = 0.0'))
subs.append(stylebox('boss_fill', C('#ff4d6d')))
props += ['BossBar/base_type = &"ProgressBar"', 'BossBar/styles/background = SubResource("boss_bg")', 'BossBar/styles/fill = SubResource("boss_fill")']
os.makedirs(f'{ROOT}/ui', exist_ok=True)
open(f'{ROOT}/ui/theme.tres', 'w').write(f'[gd_resource type="Theme" load_steps={len(subs) + 1} format=3]\n\n' + '\n'.join(subs) + '\n[resource]\n' + '\n'.join(props) + '\n')

# ------------------------------------------------------------------ scene writer
class N:
    def __init__(s, name, typ=None, children=(), inst=None, **p):
        s.name, s.typ, s.children, s.inst, s.p = name, typ, list(children), inst, p

def write_scene(root, rel):
    ext = {}
    nodes = []
    def eid(typ, path):
        if (typ, path) not in ext: ext[(typ, path)] = f'{len(ext) + 1}_{os.path.basename(path).split(".")[0]}'
        return ext[(typ, path)]
    def walk(n, parent, is_root):
        head = f'[node name="{n.name}"' + (f' type="{n.typ}"' if n.typ else '') + ('' if is_root else f' parent="{parent}"')
        if n.inst: head += f' instance=ExtResource("{eid("PackedScene", n.inst)}")'
        head += ']'
        body = []
        for k, v in n.p.items():
            if k == 'theme': v = f'ExtResource("{eid("Theme", "res://ui/theme.tres")}")'
            elif k == 'unique': k, v = 'unique_name_in_owner', 'true'
            body.append(f'{k} = {v}')
        nodes.append(head + ('\n' + '\n'.join(body) if body else '') + '\n')
        cp = '.' if is_root else (n.name if parent == '.' else parent + '/' + n.name)
        for c in n.children: walk(c, cp, False)
    walk(root, '', True)
    hdr = [f'[ext_resource type="{t}" path="{p}" id="{i}"]' for (t, p), i in ext.items()]
    out = f'{ROOT}/{rel}'; os.makedirs(os.path.dirname(out), exist_ok=True)
    open(out, 'w').write(f'[gd_scene load_steps={len(ext) + 1} format=3]\n\n' + '\n'.join(hdr) + ('\n\n' if hdr else '') + '\n'.join(nodes))

# layout helpers
def full(mode=3): return dict(layout_mode=mode, anchors_preset=15, anchor_right='1.0', anchor_bottom='1.0', grow_horizontal=2, grow_vertical=2)
IGN = dict(mouse_filter=2)
def label(name, text, var=None, **p):
    d = dict(layout_mode=2, text=S(text), horizontal_alignment=1); d.update(p)
    if var: d['theme_type_variation'] = f'&"{var}"'
    return N(name, 'Label', **d)
def button(name, text, w, secondary=False, **p):
    d = dict(layout_mode=2, custom_minimum_size=V2(w, 52), focus_mode=0, text=S(text), unique=True)
    if secondary: d['theme_type_variation'] = '&"SecondaryButton"'
    d.update(p); return N(name, 'Button', **d)
def wrap(wrapname, caption, btn, **p):
    d = dict(layout_mode=2, alignment=1); d.update(p)
    return N(wrapname, 'VBoxContainer', [label('Caption', caption, 'SmallLabel'), btn], **d)

# ------------------------------------------------------------------ HUD
heart = [(16 * math.sin(t) ** 3, -(13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t))) for t in [i * math.tau / 36 for i in range(36)]]
pts = ', '.join('%.2f, %.2f' % (x * .8, y * .8) for x, y in heart)
hearts = N('Hearts', 'HBoxContainer', [N(f'Heart{i}', 'Control', [N('Shape', 'Polygon2D', position=V2(15, 14), polygon=f'PackedVector2Array({pts})', color=C('#ff4d6d'))],
             layout_mode=2, custom_minimum_size=V2(30, 28), mouse_filter=2) for i in range(3)],
           layout_mode=1, offset_left=12.0, offset_top=10.0, offset_right=126.0, offset_bottom=40.0, mouse_filter=2, unique=True, **{'theme_override_constants/separation': 2})
hud = N('Hud', 'Control', [
    hearts,
    N('Score', 'Label', layout_mode=1, anchor_left='0.5', anchor_right='0.5', offset_left=-150.0, offset_top=6.0, offset_right=150.0, offset_bottom=46.0,
      grow_horizontal=2, text=S('0'), horizontal_alignment=1, theme_type_variation='&"ScoreLabel"', mouse_filter=2, unique=True),
    N('CoinBox', 'HBoxContainer', [
        N('CoinIcon', 'ColorRect', layout_mode=2, custom_minimum_size=V2(18, 18), size_flags_vertical=4, color=C('#ffd23f')),
        N('CoinLabel', 'Label', layout_mode=2, text=S('0'), theme_type_variation='&"ScoreLabel"', unique=True)],
      layout_mode=1, anchor_left='1.0', anchor_right='1.0', offset_left=-170.0, offset_top=6.0, offset_right=-12.0, offset_bottom=46.0,
      grow_horizontal=0, alignment=2, mouse_filter=2, unique=True, **{'theme_override_constants/separation': 8}),
    N('BossBox', 'VBoxContainer', [
        N('BossName', 'Label', layout_mode=2, text=S('Boss'), horizontal_alignment=1, theme_type_variation='&"BossLabel"', unique=True),
        N('BossBar', 'ProgressBar', layout_mode=2, custom_minimum_size=V2(0, 20), value='100.0', show_percentage='false', mouse_filter=2,
          theme_type_variation='&"BossBar"', unique=True)],
      layout_mode=1, anchor_left='0.5', anchor_right='0.5', offset_left=-160.0, offset_top=46.0, offset_right=160.0, offset_bottom=96.0,
      grow_horizontal=2, visible='false', mouse_filter=2, unique=True),
    N('Sticks', 'Control', unique=True, mouse_filter=2, **full(1)),
], theme=True, mouse_filter=2, **full(3))
write_scene(hud, 'scenes/ui/hud.tscn')

# ------------------------------------------------------------------ Menu
M16 = {f'theme_override_constants/margin_{s}': 16 for s in ('left', 'right', 'top', 'bottom')}
menu = N('Menu', 'Control', [
    N('Layout', 'MarginContainer', [N('VBox', 'VBoxContainer', [
        label('Title', 'ROOT N\nSHOOTERS', 'TitleLabel', mouse_filter=2),
        N('Spacer', 'Control', layout_mode=2, size_flags_vertical=3, mouse_filter=2),
        N('Panel', 'PanelContainer', [N('PV', 'VBoxContainer', [
            label('PickLabel', 'PICK', 'SmallLabel'),
            label('CharName', 'Crocodile Cowboy', unique=True),
            label('Dots', '●○○○○○○○○○○○○○○', 'DotsLabel', unique=True),
            label('Coins', 'COINS  0', unique=True),
            N('Row', 'HBoxContainer', [
                wrap('PlayWrap', 'PLAY', button('PlayButton', 'PLAY', 130)),
                wrap('ShopWrap', 'SHOP', button('ShopButton', 'SHOP', 100, True)),
                wrap('SoundWrap', 'SOUND', button('SoundButton', 'SOUND ON', 130, True))],
              layout_mode=2, alignment=1, **{'theme_override_constants/separation': 10})], layout_mode=2)],
          layout_mode=2, size_flags_horizontal=4)], layout_mode=2, mouse_filter=2)],
      mouse_filter=2, **full(1), **M16),
    button('PrevButton', '<', 60, True, layout_mode=1, custom_minimum_size=V2(60, 70), anchor_top='0.5', anchor_bottom='0.5',
           offset_left=10.0, offset_top=-35.0, offset_right=70.0, offset_bottom=35.0, grow_vertical=2),
    button('NextButton', '>', 60, True, layout_mode=1, custom_minimum_size=V2(60, 70), anchor_left='1.0', anchor_top='0.5', anchor_right='1.0', anchor_bottom='0.5',
           offset_left=-70.0, offset_top=-35.0, offset_right=-10.0, offset_bottom=35.0, grow_horizontal=0, grow_vertical=2),
], theme=True, mouse_filter=2, **full(3))
write_scene(menu, 'scenes/ui/menu.tscn')

# ------------------------------------------------------------------ Game over
over = N('GameOver', 'CenterContainer', [N('Panel', 'PanelContainer', [N('VBox', 'VBoxContainer', [
    label('Title', 'GAME OVER', 'OverTitle'),
    label('Message', '0\nBEST 0      COINS +0', unique=True),
    N('Row', 'HBoxContainer', [
        wrap('UpWrap', '1-UP', button('UpButton', '1-UP 200', 120, True), unique=True),
        wrap('AgainWrap', 'AGAIN', button('AgainButton', 'AGAIN', 110)),
        wrap('HomeWrap', 'HOME', button('HomeButton', 'HOME', 100, True))],
      layout_mode=2, alignment=1, **{'theme_override_constants/separation': 10})], layout_mode=2)], layout_mode=2)],
    theme=True, visible='false', mouse_filter=2, **full(3))
write_scene(over, 'scenes/ui/game_over.tscn')

# ------------------------------------------------------------------ Shop
shop = N('Shop', 'MarginContainer', [N('VBox', 'VBoxContainer', [
    N('Spacer', 'Control', layout_mode=2, size_flags_vertical=3, mouse_filter=2),
    N('Panel', 'PanelContainer', [N('PV', 'VBoxContainer', [
        label('Coins', 'COINS  0', unique=True),
        label('PrizeLabel', '', unique=True, custom_minimum_size=V2(0, 28)),
        N('Row', 'HBoxContainer', [
            wrap('SpinWrap', 'BUY', button('SpinButton', 'BUY 500', 110), unique=True),
            wrap('FreeWrap', 'FREE', button('FreeButton', 'FREE', 130), unique=True),
            wrap('OpenWrap', 'OPEN', button('OpenButton', 'OPEN', 100), unique=True),
            wrap('OkWrap', 'OK', button('OkButton', 'OK', 100), unique=True),
            wrap('BackWrap', 'BACK', button('BackButton', 'BACK', 100, True), unique=True)],
          layout_mode=2, alignment=1, **{'theme_override_constants/separation': 8})], layout_mode=2)],
      layout_mode=2, size_flags_horizontal=4)], layout_mode=2, mouse_filter=2)],
    theme=True, visible='false', mouse_filter=2, **full(3), **M16)
write_scene(shop, 'scenes/ui/shop.tscn')

# ------------------------------------------------------------------ UI root (nests the four screens)
ui = N('UI', 'CanvasLayer', [
    N('Hud', inst='res://scenes/ui/hud.tscn'), N('Menu', inst='res://scenes/ui/menu.tscn'),
    N('GameOver', inst='res://scenes/ui/game_over.tscn'), N('Shop', inst='res://scenes/ui/shop.tscn'),
    N('Flash', 'ColorRect', color=C('#ffffff', 0), mouse_filter=2, unique=True, **full(3))])
write_scene(ui, 'scenes/ui/ui.tscn')
print('ui generated')
