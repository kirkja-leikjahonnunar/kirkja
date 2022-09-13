# Voxel Village
The Voxel Village is an area within Kirkja that displays voxel creations. A fun and colorful place where the player will feel creative yet limited in the tasks and tools at hand. Within the village there are numerous quests. Upon completion of the player will be granted a Voxel Builder Lens that may be use within Void Space to create voxel creations by rotating the voxels in hand.

## Storytellers
Sprinkled throughout the village, **storytellers** are available to instill curiosity the wordcraft arts and facilitate language learning. They will take the player on a walking sim like tour of the village's tales. It could be a tour guide speech, or a fable, or interactive element.

The objective of the storytellers is to present stories that may be listened to in different languages.

### Tools
- 3D speech bubbles.
- Text, image, and layout editors.
- Triggers that activate  further material.

## Coordinate Space Levels
The objective of the **Coordinate Space Levels** are to introduce the player to the coordinate systems start-to-finish. The camera is sometimes fixed to a specific vantage point to restrict the player's attention and controls.

## Number Line ³
The player journeys through areas that have environments that increase in difficulty as the player unlocks different dimensions.

### Number Line
The number line level starts in near top down mode. The player is restricted to their trench and can only move left and right.

### Inverted Number Line

### Infinity Everywhere
The width of measurement.

#### Delta Tape Measure
Hold the tape measure and run to measure the length of the trench, field, maze, etc.

### Number Line x2
Forward.

### Number Line x3
Build up.

#### 2D Space
- Math Space
- Screen Space

### 3D Space
- LH
- RH
- Y-up

List of popular 3D coordinate systems.



## UX
**Player Journey:** Voidling > Mecha Body > Voidling > Voxel Body


### Entering the Village
Within the Mecha Body, the player runs into a dead end.
There is a small passage that is only just visible through the wall.
The player cannot enter the passage without inhabiting a Voxel Body block.
The block tumbles & slides as the player figures out its powers.

### Pedestal Forest
The player passes through

## Voxel Builder Goggles
In their main body, the player equips their Voxel Goggles _(account bound)_, then uses their laser pointer to place blocks in 3D space. The player can scroll to increase or decrease the distance of the laser pointer's end. The `initial block` hovers at the end of the laser until the player presses the `begin_voxel_editing` action. Once placed, the camera moves to focus on the voxels' center of mass _(like GW2 mount cameras)_.

The player can then orbit around the voxel creation, while their main body stays in place. The **Cursor is presented** to the user and the following default controls engage:

## Voxel Body Actions
- `voxel_place` while hovering the cursor over a voxel: **LMB.Down()**.
- `voxel_move` while dragging over
- `voxel_remove` **RMB**
- `voxel_orbit` while not hovering over a voxel: **[LMB] Drag**

## Voxel Body Features
- Save to voxel library.
- Load from voxel library.
- Edit.
- Copy.
- Paste.
- Share.
- Collaboration invitation.

## Radial Menus
- Block Types
  - Whole: cube
  - Half: prism
  - Quarter: half-a-prism
- Color Pallet:
  - Add Index Color
  - Set Index Color

![image](https://user-images.githubusercontent.com/47279470/168388813-8e76d276-b888-48e4-bd99-30c4c3a93224.png)

## Questions
- Modeling View: how can we unify the between **tool controls** and **movement controls**.
- Voxel goggles? Save, modify, copy, paste, share, allow others to collab.
- Do we need a crafting place? _(Inverted cube grid)_
- How does player place the first block.
- How to color?
- How to pick a new block type.

## Feature Request
It would be cool to be able to save the player's Voxel Builder creation as an animated GIF.  The player picks the axis-direction by clicking on the side of one of the voxels. The the animation begins slicing through the cross section of voxel layers based on the axis-direction.
