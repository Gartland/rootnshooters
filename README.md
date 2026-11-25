# Root n Shooters – Godot 4 port

Port of `Root_n_Shooters (1).html` (updated version) to Godot 4.3+ (GDScript, Compatibility renderer).
Everything is procedural (voxel boxes + synthesized audio) – there are no external assets.

## Run
1. Open Godot 4.3 or newer, click **Import**, pick `project.godot`.
2. Press **F5**.

## Controls
- Move: WASD (or left touch stick)
- Aim/shoot: mouse (hold left button), arrow keys, or right touch stick
- Menu: A/D or arrows to pick a character, Enter/Space to play
- Touch: left half of screen = move stick, right half = aim/fire stick; swipe in the menu to change character

## Scenes (meshes + nested scenes)
All models are real Godot scenes with shared mesh/material resources – open any of them in the editor and tweak boxes, colors or positions:
- `scenes/characters/char_00..14.tscn` – 15 playable characters (each nests `common/shadow.tscn`)
- `scenes/enemies/`, `scenes/bosses/`, `scenes/wingmen/` – enemy, boss and wingman models
- `scenes/pickups/` – coin, heart, gun, wingman pickups (nest `pickup_bars_*.tscn`) and the supply boxes
- `scenes/environment/` – `ground`, `cactus`, and `terrain_tile` (nests `cactus`)
- `scenes/shop/` – `prize_machine` (nests 7 `capsule_N` colors) and the capsules
- `scenes/effects/` – shield bubble, saw, zap beam; `scenes/critters/` – wand critters
- `materials/*.tres` – one shared material per color

Scenes are authored at unit size; the game scales the root (e.g. x15 for players). Nodes the code looks up by name:
`Inner`, `Inner/Tail`, `Seg*`, `Wing*`, `Spin` (animated parts), `Patch/Rock/Rock2/Cactus` (terrain tile),
`Machine`, `Machine/Crank`, `Capsule*` (shop). Keep those names if you edit a scene.
Bullets, enemy shots and particles are still spawned from code because their size/color varies per instance.

`tools/gen_scenes.py` regenerates every scene/material (`python3 tools/gen_scenes.py`) – handy for bulk changes; editing the scenes by hand is fine too, but regenerating will overwrite them.

## AdMob (optional – Game Over 1-UP)
`ads.gd` shows an AdMob **rewarded ad** when the player taps 1-UP on the Game Over screen. The free 1-UP is granted after the ad closes, only if the player earned the reward.
If ads are disabled, unsupported (desktop/web), the plugin is missing, or no ad could load, the button automatically
becomes the normal **1-UP 200** (coin cost) – and flips back to the ad option if one loads later.
Setup (Android/iOS only):
1. Create an AdMob account + app, and a **Rewarded** ad unit. Put the unit IDs in `ads.gd` (`UNIT_IDS[...]["prod"]`).
2. Install the **AdMob** plugin by *poing.studios* from AssetLib, enable it in Project Settings > Plugins.
3. Project > Tools > AdMob Download Manager: download the Android and/or iOS plugin. Enter your AdMob **App ID** in the plugin's settings (Android) / `GADApplicationIdentifier` (iOS).
4. Android export: use a Gradle/custom build and tick the AdMob plugin. iOS: follow the plugin's README after export.
5. Test with `USE_TEST_IDS = true` (default). Set it to `false` for release. Never tap your own live ads.
The 1-UP (coins or ad) can be used once per round; the button is hidden on the second Game Over.
Set `ENABLED = false` in `ads.gd` to turn ads off completely.

## Files
- `main.gd`  – game loop, enemies/bosses, weapons, pickups, menu, shop (prize machine), UI, saving
- `chars.gd` – scene loader (`Chars.inst`) + helpers for bullets/particles
- `sfx.gd`   – synthesized sound effects
- Save data: `user://save.cfg` (unlocks, coins, best score, selected character, mute)

## Version notes carried over
3 HP max, boss health bar with names, bunny weapon removed, new wave composition, halved pickup drop rates, smaller hats.

## Differences from the web version
- UI uses Godot's default font/theme (no Bungee / Rubik Mono web fonts) and text instead of SVG icons.
- Audio is re-synthesized from the same recipes (tone/noise sweeps), so it sounds similar but not identical.
