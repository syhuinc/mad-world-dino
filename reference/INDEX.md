# Art reference (Meshy spec sheets)

Reference art provided by the game's owner, used as Meshy image-to-3D input.
Real `.glb` models have now been generated from most of this art (see
below) and are wired into the game under `assets/`; this folder remains the
source of truth for exact proportions, authentic colors, and whatever
hasn't been generated yet.

## Creatures (`creatures/`)

Each spec sheet gives: type (common/rare), movement pattern, an approximate
bounding-box size as **length x width x height** (length = the horizontal
axis the creature walks along; in-game this is the lane's X axis), a color
swatch, turnaround views, and an in-game mock-up.

| File | Name | Type | Size (L x W x H) | Notes |
|---|---|---|---|---|
| `player_character_spec.png` | Explorer (player) | — | 1 tile ≈ 1 unit | red/white cap, backpack |
| `parasaurolophus_spec.png` | Parasaurolophus | Common | 2.0 x 0.8 x 1.4 | orange/tan, red stripes |
| `gallimimus_spec.png` | Gallimimus | Common | 1.8 x 0.6 x 1.6 | fastest common dino |
| `triceratops_spec.png` | Triceratops | Common | 2.4 x 1.2 x 1.4 | brown/tan, bulkiest common dino |
| `trex_spec.png` | T-Rex | Rare | 3.0 x 1.8 x 2.0 | red/orange |
| `spinosaurus_spec.png` | Spinosaurus | Rare | 3.2 x 1.6 x 1.8 | grey-blue body, red sail |
| `crocodile_spec.png` | Crocodile (river) | Common | 2.6 x 1.0 x 0.6 | green, low profile |

These exact sizes (length/width mapped to X/Z, height to Y) are used in
`scripts/LaneManager.gd`'s `_species_data()` and the crocodile setup in
`_spawn_river()`. The two rare dinosaurs are deliberately scaled up 1.4x
from the spec there — a design choice (not a reference error) so they
genuinely dominate a lane and force the "wait for the gap" moment, per the
original gameplay brief.

**Real `.glb` models exist for all 7 creatures** (generated via Meshy
image-to-3D from a clean single-subject crop of each hero shot above) and
live in `assets/creatures/`. They're loaded in `Obstacle.gd`/`Croc.gd`/
`Player.gd` via `ModelUtil.load_fitted()`, which scales and centers a model
to the exact size table above and corrects its facing (creatures face the
camera by default; the game needs a side profile, so a 90° yaw + a 180°
flip based on movement direction is applied). **Colors used in-game are
placeholder-legibility choices, not these sheets' authentic (mostly
brown/tan/red) palette** — kept that way even after real models arrived
because it reads better against the dirt lane; swap in the spec colors via
each model's material if you want strict authenticity instead of contrast.
Known cosmetic issue: the player model's backpack reconstructed as a small
separate/detached piece next to the body (a common single-image-to-3D
limitation) — not fixed, since the character is otherwise correct.

## Tiles & props (`tiles/`)

- `tile_and_prop_atlas.png` (source: `image1.png`) — unlabeled sheet of
  grass/dirt/stone/water/lava/ice/sand/road/swamp/snow tile **variants**
  (multiple decoration patterns per type) plus a few props embedded as
  tiles (log, crate, spike, stump). Not wired in; useful for future tile
  variety.
- `tile_variant_sheet_a.png` (source: `111.png`) — **the actually-labeled**
  atlas: Grass/Dirt/Stone/Water/Log/Wood Bridge tiles (row 1, World 01
  relevant), Lava/Ice/Sand/Road/Swamp/Snow tiles (row 2, future worlds),
  and standalone props with text labels (rows 3-4): Rock (Small/Large),
  Bush, Tree (Pine/Palm), Sign Post, Fence, Crystal, Mushroom, Lily Pad,
  Reed, Flower, Stone (Small), Barrel, Crate, Stump.
- `tile_variant_sheet_b.png` (source: `12.png`) — another unlabeled tile
  closeup sheet, similar to `_a`.
- `dirt_tile_closeup.png`, `grass_tile_closeup.png`, `water_tile_closeup.png`,
  `log_water_tile_closeup.png` — single-tile hero renders, already clean
  single-subject shots (no cropping needed for Meshy input).

**Real `.glb` models exist for:**
- Grass, dirt, water, stone, log tiles (`assets/tiles/*.glb`;
  grass/dirt/water generated directly from the `*_tile_closeup.png` hero
  renders, stone and log from crops of `tile_variant_sheet_a.png`'s row 1)
  — `LaneManager._make_ground()` tiles 9 individual instances of the right
  ground model across each lane's width instead of one stretched box. The
  log model doubles as a river platform: `_spawn_river()` uses it in place
  of the crocodile ~30% of the time via `Croc.gd`'s now-generic
  `model_path`/`fallback_color` params (same riding mechanics, just a log
  reskin) — the mockup's "step on crocs" is the primary mechanic, logs are
  visual variety on the same river lanes, not a separate lane type.
- Rock (small), Bush, Tree (Palm), Flower, Reed, Lily Pad (`assets/props/*.glb`,
  generated from crops of `tile_variant_sheet_a.png`'s prop rows) — used by
  `Decoration.gd` for the cosmetic edge dressing along each lane
  (`LaneManager._decorate_edges()`): Flower/Reed/Lily Pad complete the full
  prop set, replacing the last primitive placeholders in `Decoration.gd`
  (the primitive code paths remain only as a fallback if a model fails to
  load). The initial Flower/Reed crops picked up a stray artifact from the
  sprite sheet's grid — a small floating ghost shape reconstructed from a
  neighboring label's text bleeding into the crop for Flower, and two thin
  stray blades from neighboring prop bleed for Reed — both invisible in the
  2D crop preview but visible once reconstructed in 3D, and both would have
  thrown off `ModelUtil.load_fitted`'s auto-scaling since it measures the
  *combined* bounding box of every mesh in the file. Fixed by re-cropping
  tighter (fully inside each prop's own grid cell, no edge bleed) and
  regenerating; Lily Pad's original crop was already clean.

**Lane/species pairing matches the mockup's "Lane Examples" strip**, not an
even mix: `LaneManager.LaneType` is `GRASS` (safe rest), `GRASS_DANGER`
(Parasaurolophus/Gallimimus on grass), `ROCK` (Triceratops only, on the
stone tile), `DINO_RARE` (T-Rex/Spinosaurus, dirt ground), `RIVER`
(crocodiles, water ground) — Triceratops no longer shares a lane with the
faster common dinos, and grass is a hazard lane in its own right, not just
the safe-rest ground type.

**Coin** (`assets/props/coin.glb`) is also a real model, but generated
differently from everything else: there's no clean reference crop for it (the
"star coin" icon only appears in the original mockup image, which wasn't
saved to this repo), so it was generated with Meshy's *text-to-3d* endpoint
instead of image-to-3d — a text prompt describing a gold five-pointed star
coin, previewed as an untextured mesh first (to confirm the shape: it came
back as a star embossed on a circular coin rim, a good match for a "star
coin"), then refined with a texture prompt. The first refine pass used
`enable_pbr: true`, which rendered too dark/muddy under Godot's compatibility
renderer (it has no real specular IBL, so metallic materials read as flat
and dim without a reflection probe/skybox) — refining again with
`enable_pbr: false` (matching every other asset in this project) produced a
bright, flat-shaded gold texture that reads clearly in gameplay. `Coin.gd`
loads it via `ModelUtil.load_fitted()` like everything else, with the
original primitive cylinder kept as a fallback.

Not yet generated/wired: Wood Bridge tile (a distinct log-based river
crossing tile, separate from the log *platform* variant above), Tree (Pine),
Sign Post, Fence, Crystal, Mushroom, Stone (Small), Barrel, Crate, Stump, and
every Lava/Ice/Sand/Road/Swamp/Snow tile (all out of scope for World 01 —
reference for future worlds only).

## A note on the render pipeline used to verify all of this

None of the fixes/models above were guessed — this dev environment
downloaded Godot 4.3 and rendered the actual project headlessly (Xvfb +
Mesa software GL) to check every change against real screenshots. That
caught several real bugs no amount of code review would have: a camera
pointed at ungenerated ground, a squash-stretch animation running
backwards, low dino/ground contrast, a scale/rotation math bug that sheared
models when both were applied together, and — the big one — a permanent
backdrop plane sitting too close to real tile geometry, which made every
tile-based lane render as uniform green regardless of its actual type. If
you're continuing this work without that render pipeline available, treat
any new model integration as unverified until you can see it move.
