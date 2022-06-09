# Voidling

## Overview
The Voidling essentially acts as the player's 3D cursor. The player will be able to travel around the world of Kirkja looking for [_vessels_](../Vessel) to inhabit. Vessels are usually NPCs, but can be inanimate objects as well. Once the player finds an appropriate vessel, they intersect their voidling with the vessel and attempt to possess it.

## Movement
The voidling character controller should be able to access a reasonable amount of 3D space. Voidlings primarily move  forward and back, left and right, but can still fly up and down.

## Vessel Tuning
When we wish to take-up residence in a new vessel, our voidling needs to find a way to entice the vessel into allowing us to posses it. The being may need a special item or need to become attuned in different ways before getting full access to all the NPC abilities. Some NPCs can be possessed by multiple players.

### Tuning Steps
1. The player moves their voidling form to intersect with the NPCs collider.
1. The voidling indicates that tuning may be attempted.
1. Present the tuning system UI.
