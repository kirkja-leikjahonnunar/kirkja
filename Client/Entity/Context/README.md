# Context
A **context** is an inhabitable entity from which a player's [voidling](../Voidling) may request control. The amount and type of control depends on amount of affinity the context has built towards the player. Some contexts may have prerequisites that need to be met before a voidling is granted a control seat within the context. Contexts may contain multiple seats for multiple players.

## Affinity
*Values: 0 - 100*

Affinity is the measurement of how well the player is regarded by the context. The levels of affinity and the rewards for having high amounts affinity vary per context.

### Gaining Affinity for Habitation
Once we find an appropriate context, we intersect our voidling with the context and request habitation privileges. In basic contexts, the _default affinity_ is already high enough to gain a habitation seat.

> Example, an NPC quest giver allows our voidling to inhabit them in order to complete a quest. If we achieve the quest with little harm to the NPC, we gain affinity, we unlock a new ability, and they will also increase our affinity with their associates.

## Params
- Player controller.
- Character controller.
- Prerequisites & difficulty.
- Seat count & positions.
- Affinity.

## Pausing
The player uses the `Esc` key to enter pause mode. A small pocked of [void space](../../Maps/VoidSpace) opens and the context hangs out while the player chooses an action:

- Hop out of the context and continue in the current biom in voidling form.
- Twist into void space.
