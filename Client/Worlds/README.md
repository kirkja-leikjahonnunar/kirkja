# Worlds
Worlds are big playgrounds; they may be planets, or a cardiovascular system, or an ocean floor, or a computer simulation, or cell in a body, or some other plane of existence. Worlds are comprised of distinct boundaries, lawforms, and contexts ambassadors that allow voidlings to travel within different worlds.

## Bioms
Bioms are environmental systems and landscapes of the world terrain. Worlds are made up of smaller biom level maps. Attractions may be contained within a single Bioms are environmental maps.

## Context Ambassadors
Ambassadors are contexts that can travel between worlds.
Our Voidling will have to context hop between worlds. Port contexts...

## Contexts
There is no limit to the number of contexts a 

## Mounts
A mount is an entity that may be ridden. It gives perks like a speed boost or armor. They may be animals, vehicles, ect.

## Seats
A **seat** may be a node that determines the placement and orientation of the context once it mounts-up. The **maximum number of contexts** that are able to ride any one mount is determined by the size of the `seats` array.

## Fuel
The mount needs a **fuel** source to draw from. It also needs the correct type of fuel for our mount. The mount will consume the `fuel_type` as it moves an operates. The other fuel properties work together to produce UI elements.


## Properties
```gdscript
var seats : Array # Seat
var fuel_type : enum
var fuel_capacity : float # 0.0 - 1.0
var fuel_amount : float # 0.0 - 1.0
var recharge_rate : float # 0.0 - 1.0
var consumption_rate : float # 0.0 - 1.0
```
