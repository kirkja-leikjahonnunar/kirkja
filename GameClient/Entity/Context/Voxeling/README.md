# Voxeling
The **voxeling** entity is the primary context for voxel building games. Voxelings primarily inhabit the [Voxel Village]() attraction. They can move freely, jump in 3D space, wall jump, wall slide, spawn and subtract voxels, before coming to rest on a grid space.

![Voxeling form.](docs/voxeling_form.png)

## Entity Controls
| Action | Keyboard / Mouse | Gamepad | Description |
| - | :-: | :-: | - |
| camera  | `Mouselook` | `Rightstick` | Generic 3rd person camera controls. As the player rotates the camera past the 45° mark, the the voxeling hops to reorient their direction.
| move_forward | `W` | `Leftstick:` `Up` | The camera follows behind the character. |
| pivot_back | `S` | `Leftstick:` `Down` | Voxeling squats and pivots 180°, before jumping to the next block down. The camera flips behind the voxeling. |
| pivot_left | `A` | `Leftstick:` `Left` | Turn 90° CCW and hop to the adjacent grid space to the left. |
| pivot_right | `D` | `Leftstick:` `Right` | Turn 90° CW and hop to the adjacent grid space to the right.
| drop_voxel | `LMB` or `F` | `X` or `LT` | Plops down a voxel then hops on top. |
| drill_voxel | Hold `RMB` | Hold `B` or Hold `RT` | Engage drill. Use mouse look to face the block to drill. Use jump to drill down.
| jump | `Space` | `A` | Jumps 1 block in height, allowing the voxeling to hop over voxels. |
| wall_cling | Hold `Space` | Hold `A` | Requires an adjacent wall block. When falling next to a wall, holding jump will slide the voxeling to a stop on the next block. (or one more?) When the user releases the jump button, the voxeling jumps normally before starting to fall again.
| wall_slide | Release `Space` | Release `A` | Press toward wall.

## Animation
The voxeling will have a variety of animations that may have a different percentage of occurring during voxeling actions.

- Idle
- Walk
- Jump
- Fall
- Turn
- Hop
- Cling
