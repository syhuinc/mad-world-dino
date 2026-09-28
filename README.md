# Mad World: World 01 - Dino (prototype)

A Crossy Road-style lane crosser built in Godot 4. Dinosaurs are the "traffic":

- **Common (frequent, moderate danger):** Parasaurolophus, Gallimimus (fast), Triceratops (bulky, slow)
- **Rare (occasional, major danger):** T-Rex and Spinosaurus — each spans most of a lane's width, forcing you to wait for a gap before crossing
- **Rivers:** crocodiles act as moving platforms — land on one to ride across, miss and you drown

Also has: coin collection with a persistent wallet, best-distance tracking, a title screen showing your best run, pause/resume, procedurally-generated sound effects (hop/coin/death — no audio files needed) with a mute toggle, and Android back-button handling (pauses in-run, quits from the title/game-over screens).

All 7 creatures (player, T-Rex, Spinosaurus, Triceratops, Gallimimus, Parasaurolophus, crocodile), the grass/dirt/stone/water ground tiles plus a log river variant, and all edge decorations (rock/bush/palm-tree/flower/reed/lily-pad) are real Meshy-generated `.glb` models — see `reference/INDEX.md` for exactly what was generated from what (everything outside World 01's biome is still reference-only).

## Requirements

Godot **4.3+** (engine, not Godot 3.x — the project uses GDScript 2.0 / Godot 4 APIs).

## Running it

1. Open Godot 4, choose "Import", and select `project.godot` in this folder.
2. Press Play (F5). The main scene is `scenes/Main.tscn`.

Target platform is **Android** — the project is configured portrait, touch/swipe is the primary input, the renderer is set to "Mobile" (broader Android GPU compatibility than Forward+), and the Android hardware back button pauses/resumes the run.

## Controls

- **Mobile/touch (primary):** swipe in the direction you want to hop
- **Desktop (for testing in-editor):** Arrow keys or WASD to hop forward/back/left/right; `emulate_touch_from_mouse` is on so you can also test swipes with the mouse
- Pause button top-right during a run; Android back button does the same (and quits from the title/game-over screens)
- Mute button bottom-left, always visible

## Building for Android

This part needs the actual Android SDK + a JDK, which this environment doesn't have installed, so it has to happen on your machine (or in a Godot-capable CI):

1. Install Godot 4's Android export templates and, in the editor, go to **Editor > Manage Export Templates** (or install via the Android export preset's prompt).
2. Set the Android SDK path once under **Editor > Editor Settings > Export > Android** (SDK, adb, jarsigner paths).
3. In this project: **Project > Export... > Add... > Android**. Godot can auto-generate a debug keystore for local testing; you'll need your own release keystore before publishing.
4. Set the package name (e.g. `com.yourstudio.madworlddino`) and app name/icon in the Android preset.
5. Export APK/AAB, or use **Remote Deploy** with a device connected via USB (USB debugging enabled) for one-click install + play.

## Project layout

- `scripts/GameManager.gd` — autoload singleton: game state, score, coin wallet, mute setting, save/load (`user://savegame.json`)
- `scripts/Sfx.gd` — autoload singleton: procedurally synthesizes hop/coin/death tones (no audio assets) and plays them
- `scripts/Main.gd` — builds the scene at runtime (lighting, player, lane manager, camera, HUD) and drives run resets
- `scripts/Player.gd` — grid-hop movement/input, river-riding physics, collision handling
- `scripts/LaneManager.gd` — procedural lane generation (grass / common dino / rare dino / river), difficulty ramp, obstacle + coin spawning
- `scripts/Obstacle.gd` — generic dinosaur mover (color/size/speed set per species from `LaneManager._species_data`)
- `scripts/Croc.gd` — river platform mover
- `scripts/Coin.gd` — collectible
- `scripts/CameraRig.gd` — fixed-angle orthographic follow camera
- `scripts/HUD.gd` — title / in-run HUD / pause / game-over screens, built entirely in code (no hand-authored `.tscn` UI layout)
- `scripts/ModelUtil.gd` — loads a `.glb`, measures its true combined mesh bounding box, and scales/centers it (non-uniformly, per axis, with an optional yaw correction) to exactly match a target size. Used everywhere a real model replaces a primitive.
- `scripts/Decoration.gd` — cosmetic edge dressing (rock/bush/palm-tree/flower/reed/lily-pad models) placed outside the playable columns

Most gameplay logic is built procedurally at runtime rather than as hand-placed `.tscn` scene trees. `LaneManager.TILE_SIZE`/`COLS` and `Player.TILE_SIZE`/`COLS` are the main tunable knobs for scale/lane width.

## Meshy-generated assets

`assets/creatures/`, `assets/tiles/`, and `assets/props/` hold the real `.glb` models (plus their extracted texture `.jpg`s), generated via Meshy's image-to-3D API from clean single-subject crops of the reference art in `reference/`. `reference/INDEX.md` is the map: what every reference file actually is, which numbers/colors from it are wired into the code, what's already generated vs. still a primitive placeholder, and the known cosmetic issues (e.g. the player model's backpack came out as a slightly separated piece).

To generate more assets the same way: crop a clean single-subject image (see `reference/INDEX.md` for which reference sheets already work as-is vs. need cropping), POST it as a base64 data URI to Meshy's `image-to-3d` endpoint, poll until `SUCCEEDED`, download the `model_urls.glb`. Wire it in via `ModelUtil.load_fitted(path, target_size)` — it handles scale, centering, and (if the model faces the camera instead of sideways, which was true for every creature here) a yaw correction.

### Verifying changes by actually rendering them

This project was developed without a live Godot editor. Instead, the dev environment downloaded the Godot 4.3 Linux binary and ran it headlessly under `Xvfb` with Mesa's software GL renderer (`llvmpipe`), driving a temporary debug scene that builds the game, waits a few frames, and saves a screenshot — which caught several real bugs (see `reference/INDEX.md`'s last section) that would have been invisible from code review alone. Roughly:

```
LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a --server-args="-screen 0 720x1280x24" \
  /path/to/Godot_v4.3-stable_linux.x86_64 --path . \
  --rendering-driver opengl3 --rendering-method gl_compatibility \
  res://path/to/a/debug/capture/scene.tscn
```
where the debug scene's script instances `Main.tscn`, drives it (`begin_new_run()`, simulated `_try_move()` calls, etc.), and calls `get_viewport().get_texture().get_image().save_png(...)` at the points worth inspecting. Run `--headless --import` once first after adding any new binary asset (glb/png/etc.) so Godot generates its `.import` cache before the render pass. If you're changing anything visual, prefer this over guessing.
