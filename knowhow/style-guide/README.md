# Style Guide Overview
# Markdown Patterns
In an attempt to stay consistent early on...

## Legend
`Godot` > `SceneName` > `NodeName`
- ParamName: `value`
- Text: `"A awesome string!"`
- Position.x: `1.5`

### General Rules
Use the `code` markdown to denote:
- Keyboard shortcuts.
- Object classes.
- Variable names.
- Open an app to a certain UI location.


# How best to be understood on different platforms.

## Firefox > GitHub.com Markdown
### Formatting Shortcuts
- Bold:  `Ctrl` + `B`
- Italic: `Ctrl` + `I`
- Codeword: `Ctrl` + `E`


## Discord Markdown
### Formatting Shortcuts
Once we have our text selected:
- Bold: `Ctrl` + `B`
- Italic: `Ctrl` + `I`
- Underline: `Ctrl` + `U`
- Strikethrough: `?`
- Quote: `?`
- Spoiler: `?`
- Codeblock: `?`


## GDScript 4
Organizing standards for Godot scripts:
1. `extends` any parent class.
1. `class_name` name of our class.
1. `const` preload asset files.
1. `@onready var ` wait until this object is loaded to get scene nodes.
1. `export` exposed variables in the level editor.
1. `var` class variables.
1. `func _ready():` built-in functions
1. `func DoIt():` class functions.
1. `func _on_Button_pressed():` signal hooks.

_Example_

```gdscript
extends Node
class_name Village

const HOUSE: PackedScene = preload"res://House/House.tscn"
@onready var my_scene_node := $SceneNode/ChildNode

# Variable Declarations
var my_int: int = 100
var my_float: float = 0.5678
var my_string: String = "I'm a simple voidling."
var my_vector: Vector3

func _ready():
    my_vector = Vector3(-1.0, 45.0, 0.0)
    print(my_string)
```
