# Design language

Crimson Ronin translates samurai armor, ink-brush motion, and anime lighting
into interface rules rather than character decoration.

## Palette

| Role | Value |
|---|---|
| Void | `#050506` |
| Charcoal | `#0A0A0D` |
| Armor | `#111116` |
| Dark red | `#35070B` |
| Crimson | `#A70E18` |
| Active | `#E21A28` |
| Hot | `#FF2938` |
| Blade | `#F5F2EF` |
| Muted | `#90898B` |

## Motion

- Open: short opacity transition with a 96–98% scale origin.
- Close: faster collapse with no bounce.
- Workspaces: lateral slide with a restrained fade.
- Fields: 120–180 ms color and underline expansion.
- Login: one 620 ms atmospheric fade and a 460 ms panel settle.

No spinning, wobble, elastic overshoot, particles, video wallpaper, or constant
visualizer is part of the design.
