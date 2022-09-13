# Mount
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
