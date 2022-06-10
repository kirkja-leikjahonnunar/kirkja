# Voidling Overview

The **Voidling** entity essentially acts as the player's 3D in-game cursor. Voidlings are ephemeral entities that may intersect and pass through objects. As a voidling, we will be able to travel around the world of Kirkja looking for bodies to inhabit. The [**Body**](../Body) is the parent class of _inhabitable entities_ that voidlings may use to **interact** and **affect** the in-game world. Bodies are usually NPCs, but could also be animals, or inanimate objects.

## Movement
The voidling character controller should be able to access a reasonable amount of 3D space. Voidlings primarily move  forward and back, left and right, but can learn skills to fly up and down, stick to walls, and _twist_ into hidden worlds.

Voidling movement is limited by a fog-of-war, but the fog is lifted as we travel around the world in bodies.

## Body Attuning
When we wish to take-up residence in a new Body, our voidling needs to find a way to entice the Body into allowing us to posses it. The [entity](../) may need to be attuned in different ways before getting full access to all the Body abilities _(a special item, completed task, rep with similar entities, multiple inhabitants)_.

Once we find an appropriate Body, we intersect our Voidling with the Body and request habitation privileges.

### Tuning Steps
1. We position our voidling to intersect with the body's collider.
1. Our voidling indicates that tuning may be requested. _(color, sound, vibration)_
1. The body presents us with the habitation tuning system.
1. Once we've successfully inhabited the body, we can move around using the entity's abilities.
