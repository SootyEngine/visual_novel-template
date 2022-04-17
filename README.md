---
version: v0.1
godot_version: v4.0-alpha5

---
# Sooty Visual Novel

Built on [Sooty Engine](https://github.com/teebarjunk/sooty/), this is a template for creating simple [Visual Novels](https://en.wikipedia.org/wiki/Visual_novel).

Check out the [example project](https://github.com/teebarjunk/sooty-example).

# Getting Started

- Create a `res://scenes/` folder. These will be the main game scenes. They can be nested in folders.
- Create a scene like `area1.tscn`.
- Add a `SootScene` component to it.
- Create a `res://dialogue/` folder. This is where all `*.soot` files need to be. They can be nested in folders.
- Create a script like `area1.soot`.

```
// res://dialogue/area1.soot
=== START
	Welcome to Area 1.
	
	Robot and Rabbit are here.
		- Talk to Robot. => robot
		- Talk to Rabbit.
			Rabbit tends to his carrot fields.
			p: Hey [$rabbit], what's new?
			rabbit: Not much.

=== robot
	The robot tends to it's oil fields.
	p: Hey [$robot], what's new?
	robot: Not much.
```

- Before testing the scene, we will create some `State` data.
- Create a `res://states/` folder.
- Create a script like `my_states.gd`.

```
# res://states/my_states.gd
extends Node

var oil := 0
var carrots := 0

# Some character data.
var p := Character.new({name="Player", color=Color.DEEP_SKY_BLUE})
var rabbit := Character.new({name="Rabbit", color=Color.GRAY})
var robot := Character.new({name="Robot", color=Color.STEEL_BLUE})
```

Now play your scene and the text should appear.

Check out [Writing Soot](/writing_soot.md) for more info on scripting.

# Making a point and click scene.

Inside our scene we can add `Button` controls and the `SceneActionButton` component.  
When clicked, it will run the `flow` in the `soot` file with the same name as the current scene.

# Animating characters

The script `Sprite2DAnimations` has a bunch of tween animations for `Sprite2D`.  
- Add it to a `Sprite2D` in your scene.
- Add the sprite to as many groups as you want, say `my_sprite`.
- In script, call `@my_sprite.fade_in` or `@my_sprite.shake_yes` or `@my_sprite.talk` or...

*TODO*

|Call|Description|Args|
|----|-----------|----|
|`fade_in`|||
|`fade_out`|||
|`white_in`|||
|`from_left`|||
|`from_right`|||
|`talk`|Bobs up and down a little.||
|`shake_yes`|Bob up and down, flashing green.||
|`shake_no`|Bob side to side, flashing red.||
|`tilt`|||
|`shake`|||
|`move`|||

# Animating the camera

- Add the `Camera` component to your main `Camera2D`.
- Add the main camera to a group, like `camera`.

*TODO*

|Call|Description|
|----|-----------|
|`pan`||
|`center`||
|`zoom`||
|`tilt`||
|`shake`||

## Creating target cameras
- Create a dummy camera.
- Add it to group `camera_target_*` where `*` is whatever id you want.
- Add the `Camera` component to your main `Camera2D`.
- Add the main camera to a group, like `camera`.
- Call `@camera.target target_id` and your camera will interpolate to the dummy cameras position, zoom, and rotation.
- Call `@camera.target target_id true` to snap the camera instantly to the dummy cameras position, zoom, and rotation.

# Built In Flows
There are some special built in flow ids.

They are all optional.

|Flow ID|Desc|
|-------|----|
|init|Called when a scene is initialized. Will not run any dialogue, as it should be used for setting up a scene based on the `State`.|
|started|Called when a scene is entered.|
|changed:property_name|Called whenever a property is changed. Useful for changing backgrounds.|

```soot
=== scene
	=== init
		{{is_night_time}}
			@bg.set_to night_time
			@ghosts.show
		{{else}}
			@bg.set_to day_time
			@ghosts.hide
	
	=== CHANGED:is_night_time
		{{is_night_time}}
			You sense spookiness.
			player: I should get home.
			@ghosts.show
			@ghosts.animate spooky_dance

```

You can include a `MAIN.soot` file, which can have:

|Flow ID|Desc|
|-------|----|
|START|Will be called when the game starts.|
|END|Will be called when any flow ends.|
