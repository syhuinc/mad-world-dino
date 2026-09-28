# Mad World: World 01 - Dino (prototype)

A Crossy Road-style lane crosser built in Godot 4. Dinosaurs are the "traffic":

- **Common (frequent, moderate danger):** Parasaurolophus, Gallimimus (fast), Triceratops (bulky, slow)
- **Rare (occasional, major danger):** T-Rex and Spinosaurus — each spans most of a lane's width, forcing you to wait for a gap before crossing
- **Rivers:** crocodiles act as moving platforms — land on one to ride across, miss and you drown

Also has: coin collection with a persistent wallet, best-distance tracking, a title screen showing your best run, pause/resume, procedurally-generated sound effects (hop/coin/death — no audio files needed) with a mute toggle, and Android back-button handling (pauses in-run, quits from the title/game-over screens).

All visuals are placeholder primitives (boxes/capsules with flat colors) standing in for the final 3D models. No Meshy assets are wired in yet — that's the planned next step once this is playtested.

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

Almost everything is built procedurally at runtime rather than as hand-placed `.tscn` scene trees — this was authored without access to a running Godot editor to test in, so expect to need to open it and tweak numeric constants (tile size, camera distance/angle, obstacle speeds, spawn rates) once you can see it move. `LaneManager.TILE_SIZE`/`COLS` and `Player.TILE_SIZE`/`COLS` are the main knobs.

## Swapping in Meshy-generated assets

Right now dinosaurs/crocs/coins/the player are `BoxMesh`/`CapsuleMesh`/`CylinderMesh` primitives created in code. To bring in real Meshy 3D models later:

1. Generate models via Meshy (text-to-3D or image-to-3D from the reference art), export as `.glb`, and drop them under a new `assets/` folder in this project.
2. In `Obstacle.gd` / `Croc.gd` / `Coin.gd` / `Player.gd`, replace the `MeshInstance3D` + primitive-mesh block in `setup()`/`_ready()` with `load("res://assets/<file>.glb").instantiate()` (or preload the PackedScene and instance it), keeping the existing `CollisionShape3D` sizing so hit detection stays consistent with the visual scale.
3. `LaneManager._species_data()` is the single place that maps each dinosaur species to its stats — add a `model_path` key there once you have per-species `.glb` files, and read it in `_spawn_dino`.
