# Art reference (Meshy spec sheets)

Reference art provided by the game's owner, intended as Meshy image-to-3D
input once actual 3D asset generation happens (no Meshy API key is
configured in the dev environment yet — see the root `README.md`'s
"Swapping in Meshy-generated assets" section). Until then, this is the
source of truth for placeholder proportions and the eventual real colors.

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

These exact sizes (length/width mapped to X/Z, height to Y) are now used in
`scripts/LaneManager.gd`'s `_species_data()` and the crocodile setup in
`_spawn_river()`. The two rare dinosaurs are deliberately scaled up 1.4x
from the spec there — a design choice (not a reference error) so they
genuinely dominate a lane and force the "wait for the gap" moment, per the
original gameplay brief.

**Colors used in-game currently do NOT match these sheets.** The reference
palettes are mostly brown/tan/red, which reads fine on a detailed, shaded,
outlined 3D model but disappears against the dirt-lane ground when rendered
as a flat-shaded primitive box (confirmed by rendering it and comparing).
The in-game colors were deliberately shifted for contrast against a flat
placeholder box. **Once real Meshy models replace the primitives, restore
each species' authentic palette from its spec sheet** — the improved
shading/silhouette of a real model should keep it readable even on
similarly-colored ground.

## Tiles & props (`tiles/`)

- `tile_and_prop_atlas.png` — labeled atlas: Grass/Dirt/Stone/Water/Log/Wood
  Bridge tiles (World 01 relevant), plus Lava/Ice/Sand/Road/Swamp/Snow tiles
  (future worlds, not used yet), plus decorative props: rocks, bushes,
  trees (pine/palm), sign post, fence, crystal, mushroom, lily pad, reed,
  flower, barrel, crate, stump.
- `tile_variant_sheet_a.png` / `tile_variant_sheet_b.png` — unlabeled
  closeup variants of grass/dirt/stone/water tiles (multiple decoration
  patterns per type).
- `dirt_tile_closeup.png`, `grass_tile_closeup.png`, `water_tile_closeup.png`,
  `log_water_tile_closeup.png` — single-tile hero renders.

None of these are wired into the game yet. The current lane ground is a
single flat-colored box per lane (grass/dirt/river) in
`LaneManager._make_ground()`. Only grass, dirt and water tiles (plus maybe
log/wood-bridge for river crossings) are relevant to World 01; the other
tile types are reference for later worlds and out of scope here.
