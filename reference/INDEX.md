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
- Grass, dirt, water tiles (`assets/tiles/*.glb`, generated directly from
  the `*_tile_closeup.png` hero renders) — `LaneManager._make_ground()`
  tiles 9 individual instances of the right model across each lane's
  width instead of one stretched box.
- Rock (small), Bush, Tree (Palm) (`assets/props/*.glb`, generated from
  crops of `tile_variant_sheet_a.png`'s prop row) — used by
  `Decoration.gd` for the cosmetic edge dressing along each lane
  (`LaneManager._decorate_edges()`); Flower/Reed/Lily Pad in `Decoration.gd`
  are still simple primitives, not yet generated.

Not yet generated/wired: Stone tile, Log/Wood Bridge tile (for a log-based
river crossing variant), Tree (Pine), Sign Post, Fence, Crystal, Mushroom,
Stone (Small), Barrel, Crate, Stump, and every Lava/Ice/Sand/Road/Swamp/Snow
tile (all out of scope for World 01 — reference for future worlds only).

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
