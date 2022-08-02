TODO
====

- GameClient:
    - [ ] controller can't operate the pause menu
    - [ ] proximity buttons: need to not be entirely proximity driven.. whether hovered, clickable should still determined by player direction, and only activate one at a time
    - [ ] finish implementing log off
    - [ ] needs to be able to cover from GameServer vanishing
    - [ ] debug latency updating.. not rendering at correct time equivalent?
    - [ ] npcs/platforms/other moveable scene furniture must be network synced:
        - [ ] furniture state needs to be established on player login
        - [x] DONE base event passing
    - [ ] screen names, not just client ids
    - we should have bad language filter for screen names, ANY other player input
    - [x] despawned players spawn again
    - [x] while playing: esc to bring up menu, then esc closes menu (not quit). have button to quit
    - [x] make volume sliders boop as you slide them

- networking:
    - [ ] double check player crash despawn race conditions
    - [ ] reset the latency clock every day or so, otherwise latency diffs get too divergent from reality
    - [ ] record current server of player in db? last login/logoff time?
    - [ ] record accumulated time played
    - [ ] extra security: check that server calling funcs is actually id == 1 for EVERY client func... does @rpc cover that?
    - [ ] for really fast stuff, lag compensation, do some extrapolate on some action to predict time sequence of actual clients
    - [ ] load balancing.. how to add/remove servers on the fly as clients come and go. Currently hardcoded to GameServer1. auth needs to return server url/port?

- network security
    - [ ] When releasing, REMEMBER TO REMOVE our phony encryption certificate, and replace with something responsible
    - [ ] 2fa? sms? trust device from mac addr?


- [ ] do we need server side map/collision? test?

- [ ] bug: windows sqlite not working Godot alpha 9, not working anywhere with Alpha 10
- [ ] implement gameserver world database
- [ ] databases: see Game Development Center's discord for big discussion? See Sigrid's database modules for dbs other than sqlite

- [ ] despawning: typical is wait several seconds on user log off, turn off physics for player, so other clients can stay synced
 
- [ ] export port number across projects

- [ ] how to load test?

- [ ] loading scene progress bar?  ->  see: `https://docs.godotengine.org/en/3.5/tutorials/io/background_loading.html`

- [ ] c++ optimizing if necessary at some point

- [x] debug: seems like when gameserver is stopped and started, auth server errors
- [x] Send world state to new clients on login
- [x] in G4a9: godot bug: timer.timeout warning about await not being needed: https://github.com/godotengine/godot/issues/58156
- [x] FIXME: restarting game server should not make auth/gateway fault out
- [x] implement register
- [x] FIX: Despawn not syncing


NOTES
-----
- Godot hard limit 4095 concurrent players per network (ccu)
- requests per second (rps) 
- x509 certificate cost 3rd party verification, cost estimate: ~ $25 / year
- NEVER let crypto key get on Client, only cert, Gateway gets both key and cert.
- password hashing: 
      slow: bcrypt, scrypt, lyra2, argon2  <-  not integrated in godot
      fast: sha, sha2


Research
--------
- Godot voice over ip: https://github.com/c-as/godot-voip


Unanswered Questions
--------------------
- Does godot have something like Debug.Log that get removed at export time? functionally like commenting out dbg statements?

- which runs first, singleton or main scene?


Answered Questions
------------------



PORTING NOTES
-------------
...from porting things to Godot 4.0

```
get_tree().set_network_peer()   ->   ??? custom_multiplayer.set_root_path("/GatewayServer")
custom_multiplayer.set_network_peer(network)   ->   custom_multiplayer.set_multiplayer_peer(network)
but now custom_multiplayer has been removed in favor of set_multiplayer()
custom_multiplayer  ->  get_tree().set_multiplayer(your_multiplayerapi, "/path/to/branch")
custom_multiplayer.poll() not really needed explicitly, now: get_tree().multiplayer_poll = true (which is default)
```

`int(string)?  <--  String.to_int()`

`get_tree().get_rpc_sender_id()`  ->  `multiplayer.get_remote_sender_id()`

`game_server.network.disconnect_peer(game_client_id)`  ->  `game_server.network.get_peer(game_client_id).peer_disconnect()`

shader:
    hint rework: https://github.com/godotengine/godot/pull/61554
        hint_color, hint_albedo are now: source_color
        hint_white -> hint_default_white
        hint_black -> hint_default_black


CHEATSHEET
----------
- One off timers (4.0):  `get_tree().create_timer(1.0).timeout.connect(YourFunction)`
- Blocking timer (4.0):  `await get_tree().create_timer(1.0).timeout`


Kirkja Custom Addons (todo)
---------------------------
- Markdown preview within Godot. See also this existing godot-proposal: https://github.com/godotengine/godot-proposals/issues/139
- Streamline Blender to Godot workflow


GRIPES
------
Text editor needs to be its own window

should be able to drag nodes to inspector for a different object, alpha 7 makes it go away on click on the node

see also current github issues around 4.0: https://github.com/godotengine/godot/issues?q=is%3Aissue+is%3Aopen+milestone%3A4.0+label%3Abug+

auto complete, would be nice to search only in bottom most class items

Searching editor settings i.e. "port", does not search across all sections!!!!!

in filesystem panel, add new scene, creates new scene but does not save immediately

Script editor:
    when you collapse the file list, should still show current file name, maybe on the collapse bar (currently just dead space)
    need better script file navigation, ie next file/ prev file


BLENDER GRIPES
--------------
- The post action panel that shows up only right after a tool (like add mesh) could be more meaningful, or just be a modifier instead


