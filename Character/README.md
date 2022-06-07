# Character

A generic 3rd/1st person character controller in Godot.

The controller is contained within the ThirdPerson directory. So, nothing inside there should
refer to anything outside that directory.

This repo is for various experimental prototyping of the character controller for the Kirkja game.
When a feature is stable, it will be imported to the kirkja/GameClient project.


## Setting up

### Proxy distance nodes

The Player object has several `Proxy_*` nodes that let you visually set up various
distances that control how the camera will avoid colliding with the player.

TODO: This should be remade with some kind of gizmo plugin, instead of nodes 

- `Proxy_Left`, `Proxy_Right`, and `Proxy_Over` control the horizontal distance away from the player, so
  the 3rd person view will show the player off to the left or right, or centered
- `Proxy_Back` is how much in front or behind the camera view should be when you are looking down
  from above, or up from below
- `Proxy_FPS` is the spot to place the camera in 1st person view


### Camera

The MainCamera is the actual rendering camera, which lerps to the "camera" in the CameraRig tree.
TODO: This potentially allows adaptation to taking over the camera to look at points of interest.


## TODO

### BUGS
- Crash trying to open with Alpha 8
- player clips through the fast rotating lever platform
- can't push rigidbodies that are just lying around -> something to do with non-bidirectional mask-layer combos
- need to lerp velocity, diff lerp for in air?, continue velocity when in air regardless of sprint?
- key binding window needs 3 alts, ie for movement, allow any of wasd, up/down/left/right, gamepad

### Basic modes and configuration
- [x] 3rd person mode
- [ ] 3rd person aiming (like 3rd, but different hover config and fov)
- [x] 1st person mode (change by a toggle or wheel in and out)
- [ ] vr mode
- [x] Mouse and keyboard controller
- [ ] Game controller support
- [x] Camera hover configuration targets
- [ ] Make sure it works on non-constant gravity/up directions
- [ ] Be able to inhabit other objects to move them around
- [ ] be able to drag/push objects around
- [ ] moving platforms
- [x] Config window (at proof of concept level at least)

### Movement types
- [x] run/walk
- [ ] glide
- [ ] fly
- [ ] swim
- [ ] ice skating/ball rolling
- [ ] driving/mounts
- [ ] ropes and swinging
- [ ] skinny plank walk
- [ ] parkour/free run
  - [ ] sliding down inclines
  - [ ] cat grab
  - [ ] lazy vault
  - [ ] kong vault
  - [ ] wall run
  - [ ] roll
  - [ ] tic tac
  - [ ] precision jump
  - [ ] bar swing, lache
  - [ ] bar kip
  - [ ] flip
  - [ ] underbar
- [ ] climb
  - [ ] free climb
  - [ ] ledge climb
  - [ ] pole climb/slide
  - [ ] ladders

### Modeling, animations, ik
- [ ] default model with various animations.. use GDQuest's mannequin?
- [ ] head look ik
- [ ] walking on stairs ik
- [ ] ladder ik
- [ ] foot ik placement
- [ ] item holding, hand ik placement?
- [ ] throwing stuff
- [ ] hand poses
- [ ] reach indicator
- [ ] dances?
