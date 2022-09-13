# Worlds
Worlds are big playgrounds; they may be planets, or a cardiovascular system, or an ocean floor, or a computer simulation, or cell in a body, or some other plane of existence. Worlds are comprised of distinct boundaries, lawforms, and contexts ambassadors that allow voidlings to travel within different worlds.

## Bioms
Bioms are environmental systems and landscapes of the world terrain. Worlds are made up of smaller biom level maps. Attractions may be contained within a single Bioms are environmental maps.

## Maps
The **Maps** folder contains Godot scenes that act as levels or parts of a level. Maps are loaded as and unloaded as needed as we travel around the Kirkja world.

## Contexts
There is no limit to the number of contexts a world can have.

A **context** is an entity from which a player's [voidling](../Voidling) may request control. The amount and type of control depends on amount of affinity the context has built towards the player. Some contexts may have prerequisites that need to be met before a voidling is granted a _control seat_ within the context. May contexts may contain multiple seats for multiple players?

## Affinity
*Values: `0` - `100`*

Affinity is the measurement of how well the player is regarded by the context. The levels of affinity and the rewards for having high amounts affinity vary per context.

### Gaining Affinity
Once we find an appropriate context to hop in, we intersect our voidling with the context and request habitation privileges. In basic contexts, the _default affinity_ is already high enough to gain a control seat.

> Example, an NPC quest giver could allow our voidling to inhabit them in order to complete a particular quest. If we achieve the quest with little harm to the NPC, we gain more affinity that if we completed it with serious harm.  We unlock new context abilities, as we progress, and gain the trust of their associates, allowing us to grow into new contexts.

### Params
- Player controller.
- Character controller.
- Prerequisites & difficulty.
- Seat count & positions.
- Affinity.

### Ambassadors
Ambassadors are contexts who can travel between worlds. Voidlings may only twist between worlds with an ambassador with **port privileges** in both worlds.

### Pausing
The player uses the `Esc` key to enter pause mode. A small pocked of [void space](../../Maps/VoidSpace) opens and the context hangs out while the player chooses an action:

- Hop out of the context and continue in the current biom in voidling form.
- Twist into void space.

## Mounts
A mount is an entity that may be ridden. It gives perks like a speed boost or armor. They may be animals, vehicles, ect.

### Seats
A **seat** may be a node that determines the placement and orientation of the context once we mounts-up. The **maximum number of contexts** that are able to ride any one mount is determined by the size of the `seats` array.

### Fuel
The mount needs a **fuel** source to draw from. It also needs the correct type of fuel for our mount. The mount will consume the `fuel_type` as it moves an operates. The other fuel properties work together to produce UI elements.


### Properties
```gdscript
var seats : Array # Seat
var fuel_type : enum
var fuel_capacity : float # 0.0 - 1.0
var fuel_amount : float # 0.0 - 1.0
var recharge_rate : float # 0.0 - 1.0
var consumption_rate : float # 0.0 - 1.0
```
