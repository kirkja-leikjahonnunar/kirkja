extends Control


@export var LoginWindow : NodePath
@export var OptionsWindow : NodePath
@export var OverlayHaze : NodePath

var login_window
var options_window
var overlay_haze

var current_submenu


enum GameState { Startup, Online, PlayingOffline }
var game_state = GameState.Startup


func _ready():
	GameStateChange(GameState.Startup)
	
	if not OverlayHaze.is_empty():   overlay_haze   = get_node(OverlayHaze)
	if not LoginWindow.is_empty():   login_window   = get_node(LoginWindow)
	if not OptionsWindow.is_empty(): options_window = get_node(OptionsWindow)
	
	if login_window: login_window.visible = false
	if options_window: options_window.visible = false
	if overlay_haze: overlay_haze.visible = true
	
	GameServer.logged_on.connect(_on_logged_on)
	GameServer.logged_off.connect(_on_logged_off)


#---------------------- GameServer signals -------------------------------

func _on_logged_on():
	print ("PauseMenu got logged on")
	GameStateChange(GameState.Online)
	ClosePauseMenu()

func _on_logged_off():
	print ("PauseMenu got logged off")
	GameStateChange(GameState.PlayingOffline)
	OpenPauseMenu()


#-------------------------- State change functions -------------------------------

func GameStateChange(new_state):
	match new_state:
		GameState.Startup:
			$VBoxContainer/Resume.visible = false
			$VBoxContainer/Login.visible = true
			$VBoxContainer/Login.text = "Log in"
			$VBoxContainer/PlayOffline.visible = true
		GameState.Online:
			$VBoxContainer/Resume.visible = true
			$VBoxContainer/Login.visible = true
			$VBoxContainer/Login.text = "Log out"
			$VBoxContainer/PlayOffline.visible = true
		GameState.PlayingOffline:
			$VBoxContainer/Resume.visible = true
			$VBoxContainer/Login.visible = true
			$VBoxContainer/Login.text = "Log in"
			$VBoxContainer/PlayOffline.visible = false
	game_state = new_state


#-------------------------------- Events -----------------------------------------

func _unhandled_key_input(event):
	if event is InputEventKey:
		if event.physical_keycode == KEY_ESCAPE && event.pressed == false:
			print ("Pause menu got unhandled escape")
			if current_submenu != null:
				current_submenu.visible = false
				current_submenu = null
				visible = true
			else:
				if visible:
					if game_state == GameState.Online || game_state == GameState.PlayingOffline:
						ClosePauseMenu()
				else:
					OpenPauseMenu()
			get_viewport().set_input_as_handled()

func OpenPauseMenu():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	visible = true
	if overlay_haze: overlay_haze.visible = true

func ClosePauseMenu():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if current_submenu:
		current_submenu.visible = false
		current_submenu = null
	visible = false
	if overlay_haze: overlay_haze.visible = false


func _on_resume_pressed():
	# button should have been visible only if paused
	ClosePauseMenu()


func _on_play_offline_pressed():
	# if logged in, log off and continue map
	# if not logged in, start map
	if game_state == GameState.Startup:
		GameServer.SpawnOfflinePlayer(Vector3(0,1,0), Quaternion()) #FIXME: need more systematic spawn point per map
		GameStateChange(GameState.PlayingOffline)
		ClosePauseMenu()
	elif game_state == GameState.Online:
		# need to log off
		push_error("NEED TO IMPLEMENT log off")
		GameStateChange(GameState.PlayingOffline)


func _on_login_pressed():
	# Turn on Login/Register menu, push pause menu
	login_window.visible = true
	login_window.parent_menu = self
	current_submenu = login_window
	visible = false


# Turn on Options menu, push pause menu
func _on_options_pressed():
	visible = false
	options_window.visible = true
	options_window.parent_menu = self
	current_submenu = options_window


func _on_account_pressed():
	push_error("TODO: IMPLEMENT ACCOUNT")


func _on_quit_pressed():
	print ("Quitting!")
	get_tree().quit()
