#fresh from 12:30am 1-15-23
class_name Player

extends KinematicBody2D

var player_position

var jump_location
var current_location

# experiment info
var open_movement = false
var velocity = Vector2.ZERO
var gravx = 0
var gravy = -1
var func_delta = 0
#var player_is_on_floor = false #true if starting state is idle, not fall

# export variables
export var speed := 80.00
export var jump_strength := -280.00
export var gravity := 800.00
export var fall_damage_rebound := -10.00


var sprite_flip = false

#climbing booleans
var climbing = false
var allow_climbing = false


# falling damage booleans
var too_high = false
var stop_state = false
var allow_up = false
var grounded = false
var open_idle = false

# state booleans
var fall_damage = false
var running = false
var walking = false
var falling = true # start game falling

#open movement booleans
var open_direction_bg_active = false #must start level outside of open_direction!
var adjust_collision = false


var active_jumping = false
var start_check = false


#starting movement:
var horizontal_direction = (Input.get_action_strength("ui_right") - 
Input.get_action_strength("ui_left"))

var vertical_direction = (Input.get_action_strength("ui_down") -
Input.get_action_strength("ui_up")) #for open_movement experiment



enum PLAYER_STATE {
	IDLING,
	JUMPING,
	FALLING,
	CLIMBING_UP,
	CLIMBING_DOWN,
	CLIMBING_IDLING,
	CLIMBING_RIGHT,
	CLIMBING_LEFT,
	FALL_DAMAGE,
	RUNNING,
	WALKING,
}

#ARRAY VARIABLES
var current_state = PLAYER_STATE.IDLING
var _state_array = [PLAYER_STATE.IDLING, PLAYER_STATE.IDLING]





################################################################################
################################################################################
#
# MATCH CURRENT STATE / PROCESS DELTA
#
################################################################################
################################################################################

func _process(_delta):


	match current_state:
		
#### NOTES DON'T PUT VELOCITY.X/Y HERE. JUST GRAVITY??? PUT VELOCITY.X/Y IN ***PHYSICS*** PROCESS DELTAS
#### EVERY FRAME _process(delta) will check to see if current_state matches PLAYER_STATE.STATE then RUN nested functions each delta
		PLAYER_STATE.IDLING:
			adjust_collision = false
			if grounded:
				_turn_off_gravity(80)
				_handle_array(PLAYER_STATE.IDLING, "Idle")
				
#			if top_stop and Input.is_action_just_pressed("ui_up"):
#				velocity.y = 0
			if too_high:
				show_damage_effect()
				
		PLAYER_STATE.JUMPING:
			_turn_on_gravity()
			adjust_collision = false
			_handle_array(PLAYER_STATE.JUMPING, "Jump_Launch")
			
			
		PLAYER_STATE.FALLING:
			adjust_collision = false
			_turn_on_gravity()
			_handle_array(PLAYER_STATE.FALLING, "Jump_Fall")
#			climbing = false
#			if grounded:
#				_turn_off_gravity(80)
#				current_state = PLAYER_STATE.IDLING
			#print("ENUM FALLING")
		
		PLAYER_STATE.WALKING:
			adjust_collision = false
			if grounded:
				_turn_off_gravity(80)
				#GRAVITY DOESN'T WORK HERE BECAUSE GRAVITY IS NEEDED FOR INPUT MOVEMENTS IN IF STATEMENTS
				_handle_array(PLAYER_STATE.WALKING, "Walk")
				
				#print("ENUM WALKING")
				
#			if is_zero_approx(velocity.x) and is_zero_approx(velocity.y):
#				current_state = PLAYER_STATE.IDLING

			
		PLAYER_STATE.CLIMBING_UP:
			adjust_collision = true
			_toggle_gravity(0,0)
			_handle_array(PLAYER_STATE.CLIMBING_UP, "Climb_Up_New")
			#get_node("CLIMBDTC").position = Vector2(4,-1)

			#print("CLIMB_UP ENUM")

		PLAYER_STATE.CLIMBING_DOWN:
			adjust_collision = true
			_toggle_gravity(0,0)
			_handle_array(PLAYER_STATE.CLIMBING_DOWN, "Climb_Down_New")
			#get_node("CLIMBDTC").position = Vector2(4,-1)
			#print("CLIMB_DOWN ENUM")
		
		PLAYER_STATE.CLIMBING_IDLING:
			adjust_collision = true
			_turn_off_gravity(80)
			#_toggle_gravity(0,0)
			_handle_array(PLAYER_STATE.CLIMBING_IDLING, "Climb_Idle")
			#print("CLIMBING_IDLING ENUM")
			
		PLAYER_STATE.CLIMBING_RIGHT:
			adjust_collision = true
			_toggle_gravity2(0,0)
			_handle_array(PLAYER_STATE.CLIMBING_RIGHT, "Climb_Up_New")
			#print("CLIMBING_IDLING RIGHT")

				
		PLAYER_STATE.CLIMBING_LEFT:
			adjust_collision = true
			_toggle_gravity2(0,0)
			_handle_array(PLAYER_STATE.CLIMBING_LEFT, "Climb_Down_New")
			#print("CLIMBING_IDLING LEFT")
				
		PLAYER_STATE.FALL_DAMAGE:
			adjust_collision = false
			_handle_array(PLAYER_STATE.FALL_DAMAGE, "Jump_Land")
				
		PLAYER_STATE.RUNNING:
			adjust_collision = false
			if grounded:
				_turn_off_gravity(210)
#				speed = 210.00
				#climbing = false
				_handle_array(PLAYER_STATE.RUNNING, "Running")
			
			
			
			
			
			
			
			
			
			
################################################################################
################################################################################
#
# READY
#
################################################################################
################################################################################

func _ready():
	
	#start position of collision shapes
	get_node("OpenDirDTC/OpenDirDTC").position = Vector2(3,-10)
	get_node("GroundDTC").position = Vector2(3,-9)
	get_node("CLIMBDTC").position = Vector2(4,-1)

	
	

	#signals
	var climbsignalGO = get_tree().get_root().find_node("Level1", true, false)
	climbsignalGO.connect("ClimbGO", self, "handle_ClimbGO")
	var climbsignalSTOP = get_tree().get_root().find_node("Level1", true, false)
	climbsignalSTOP.connect("ClimbSTOP", self, "handle_ClimbSTOP")
	var OpenDirGO = get_tree().get_root().find_node("Level1", true, false)
	OpenDirGO.connect("OpenDirGO", self, "handle_OpenDirGO")
	var OpenDirSTOP = get_tree().get_root().find_node("Level1", true, false)
	OpenDirSTOP.connect("OpenDirSTOP", self, "handle_OpenDirSTOP")
	var OpenCollideGO = get_tree().get_root().find_node("Level1", true, false)
	OpenCollideGO.connect("OpenCollideGO", self, "handle_OpenCollideGO")
	var OpenCollideSTOP = get_tree().get_root().find_node("Level1", true, false)
	OpenCollideSTOP.connect("OpenCollideSTOP", self, "handle_OpenCollideSTOP")

	
	
	
	
################################################################################
################################################################################
#
# PHYSICS PROCESS DELTA
#
################################################################################
################################################################################



#SEARCH KEYWORD: #delta
	
#STATE MACHINE PART 2 (TYPE 2)
func _physics_process(delta):
	func_delta = delta
	
	#JUMP
	if _allow_jump() and Input.is_action_just_pressed("ui_jump"):
		_start_jump()


	
	#FALL
	_new_falling_prerecs()
	_new_falling()

	if open_direction_bg_active:
		print("grounded")
	if !open_direction_bg_active:
		print("NOT grounded")

	
	if climbing:
		if adjust_collision and sprite_flip:
			sprite_flip = true
			var flipvalue = 2
			var correctionvalue = 1
			var shiftvalue = 11
			#print("climb not flip")
			get_node("OpenDirDTC/OpenDirDTC").position = Vector2((3-flipvalue-shiftvalue),-10)
			get_node("GroundDTC").position = Vector2((3-flipvalue-shiftvalue),-9)
			get_node("CLIMBDTC").position = Vector2((4+correctionvalue-shiftvalue),-1)
			if grounded:
				get_node("Sprite").set_flip_h(true)
				get_node("OpenDirDTC/OpenDirDTC").position = Vector2((3-6),(-10))
				get_node("GroundDTC").position = Vector2((3-6),(-9))
				get_node("CLIMBDTC").position = Vector2((4-1),(-1))
				
	if climbing:
		if adjust_collision and not sprite_flip:
			sprite_flip = false
			var flipvalue = 2
			var correctionvalue = 1
			#print("climb not flip")
			get_node("OpenDirDTC/OpenDirDTC").position = Vector2((3-flipvalue),-10)
			get_node("GroundDTC").position = Vector2((3-flipvalue),-9)
			get_node("CLIMBDTC").position = Vector2((4+correctionvalue),-1)	
			if grounded:
				sprite_flip = false
				get_node("Sprite").set_flip_h(false)
				get_node("OpenDirDTC/OpenDirDTC").position = Vector2(3,-10)
				get_node("GroundDTC").position = Vector2(3,-9)
				get_node("CLIMBDTC").position = Vector2(4,-1)
	
		
	
	if not active_jumping:
		if _check_top_stop():
			#print("top_stop")
			_handle_top_stop()


	_walking()
	_running()
	_idling()

	
	if _allow_climbing():
		_start_climbing()
		
	_active_climb()


################################################################################
################################################################################
#
# FUNCTIONS
#
################################################################################
################################################################################

		

#JUMP # JUMP ##JUMP
func _allow_jump():
	if current_state == PLAYER_STATE.FALLING:
		return false
	if current_state == PLAYER_STATE.FALL_DAMAGE:
		return false
	if current_state == PLAYER_STATE.JUMPING:
		return false
	return true
		
func _start_jump(): 
	active_jumping = true
	current_state = PLAYER_STATE.JUMPING
	velocity.y = jump_strength
	grounded = false
	var JumpTimer = $JumpTimer
	JumpTimer.start()
		
func _on_JumpTimer_timeout():
	_end_jump()

		
func _end_jump():
	active_jumping = false
	if open_direction_bg_active:
		grounded = true
		#print("end jump grounded")
	if !open_direction_bg_active:
		grounded = false
		#print("end jump ungrounded")
		_turn_on_gravity()


#FALL # FALL ##FALL
func _new_falling_prerecs():
	if current_state == PLAYER_STATE.CLIMBING_IDLING:
		falling = false
		climbing = true
	if !grounded:
		falling = true
	if !grounded and climbing:
		falling = false
	if grounded:
		falling = false
	if climbing:
		falling = false

		

func _new_falling():
	if falling:
		current_state = PLAYER_STATE.FALLING
	if !falling:
		current_state = PLAYER_STATE.IDLING
	
func _allow_climbing():
	if !allow_up and allow_climbing:
		#top_stop = false
		return true
		
	if !grounded and allow_climbing: ##################
		return true
		
	if !allow_climbing:
		climbing = false
		return false
	
	if grounded:
		climbing = false
		return false
		
	
func _climb_up():
	
	if 	(
		_allow_climbing()
		):
		current_state = PLAYER_STATE.CLIMBING_UP
		#print("func _climb_up()")
		velocity.y = -50
#	if !allow_climbing and grounded:
#		current_state = PLAYER_STATE.IDLING
#	if !allow_climbing and not grounded:
#		current_state = PLAYER_STATE.FALLING

func _climb_down():
	if 	(
		_allow_climbing()
		):
		current_state = PLAYER_STATE.CLIMBING_DOWN
		#print("func _climb_down()")
		velocity.y = 50
#	if !allow_climbing and grounded:
#		current_state = PLAYER_STATE.IDLING
#	if !allow_climbing and not grounded:
#		current_state = PLAYER_STATE.FALLING

	
func _climb_right():
	if 	(
		_allow_climbing()
		):
		current_state = PLAYER_STATE.CLIMBING_RIGHT
		#print("func _climb_right()")
		velocity.x = 50
#	if !allow_climbing and grounded:
#		current_state = PLAYER_STATE.IDLING
#	if !allow_climbing and not grounded:
#		current_state = PLAYER_STATE.FALLING
			

func _climb_left():
	if 	(
		_allow_climbing()
		):
		current_state = PLAYER_STATE.CLIMBING_LEFT
		#print("func _climb_left()")
		velocity.x = -50
#	if !allow_climbing and grounded:
#		current_state = PLAYER_STATE.IDLING
#	if !allow_climbing and not grounded:
#		current_state = PLAYER_STATE.FALLING

	

			
func _walking():
	
	#WAlKING
	if 	(
		!is_zero_approx(velocity.x)
		and not climbing
		and grounded
		and not running
		):
		current_state = PLAYER_STATE.WALKING
		
	if 	(
		!is_zero_approx(velocity.y)
		and not climbing
		and grounded
		and not running
		and allow_up
		):
		current_state = PLAYER_STATE.WALKING

func _idling():
	#IDLING
	if 	(
		is_zero_approx(velocity.x)
		and is_zero_approx(velocity.y)
		and not climbing
		and grounded
		):
		current_state = PLAYER_STATE.IDLING
#

		
func _running():
	#ACTIVATE RUN
	if Input.is_action_pressed("ui_run"):
		running = true

	if Input.is_action_just_released("ui_run"):
		running = false
#
	
	if 	(!is_zero_approx(velocity.x)
		#and not climbing
		and grounded
		and running
		):
		current_state = PLAYER_STATE.RUNNING
		
	if 	(!is_zero_approx(velocity.y)
		#and not climbing
		and grounded
		and running
		#and allow_up
		):
		current_state = PLAYER_STATE.RUNNING
	
func _check_top_stop():
	if allow_climbing:
		return false
	if !grounded:
		return false
	if climbing:
		return false
	if allow_up:
		return false
	return true
	

		


func _handle_top_stop():

		if !allow_up: #ORIGINAL
			velocity.y = 0
		if Input.is_action_pressed("ui_run") and Input.is_action_pressed("ui_up"):
			current_state = PLAYER_STATE.IDLING
			#print("T01")

		if Input.is_action_pressed("ui_down"):
			velocity.y = speed
			current_state = PLAYER_STATE.WALKING





func _turn_off_gravity(speedchange):
	if grounded:
		gravx = 0
		gravy = 0
		
		velocity = move_and_slide(velocity, Vector2(gravx,gravy))
		
		horizontal_direction = (Input.get_action_strength("ui_right") -
		Input.get_action_strength("ui_left"))
		vertical_direction = (Input.get_action_strength("ui_down") -
		Input.get_action_strength("ui_up"))
		

		velocity.x = horizontal_direction * speedchange
		velocity.y = vertical_direction * speedchange
		
	
	#Sprite flip GOING LEFT
	if 	(
		horizontal_direction < 0
		#and not adjust_collision
		and not stop_state
		): handle_sprite_flip()
		
	#Sprite flip GOING RIGHT
	if 	(
		horizontal_direction > 0
		#and not adjust_collision
		and not stop_state
		): handle_sprite_unflip()
		

func _turn_on_gravity():
	if !grounded:
		gravx = 0
		gravy = -1
		

		
		velocity = move_and_slide(velocity, Vector2(gravx,gravy))
		
		horizontal_direction = (Input.get_action_strength("ui_right") -
		Input.get_action_strength("ui_left"))

		velocity.x = horizontal_direction * speed
		velocity.y += gravity * func_delta
		
	#Sprite flip GOING LEFT
	if (
		horizontal_direction < 0
		#and not adjust_collision
		and not stop_state
		): handle_sprite_flip()
		
	#Sprite flip GOING RIGHT
	if (
		horizontal_direction > 0
		#and not adjust_collision
		and not stop_state
		): handle_sprite_unflip()
		
		
	
func _toggle_gravity(a,b):
	gravx = a
	gravy = b
	
	velocity = move_and_slide(velocity, Vector2(gravx,gravy))
	
	horizontal_direction = (Input.get_action_strength("ui_right") -
	Input.get_action_strength("ui_left"))
	vertical_direction = (Input.get_action_strength("ui_down") -
	Input.get_action_strength("ui_up"))
	

	velocity.x = horizontal_direction * speed
	velocity.y = vertical_direction * speed
	
	#Sprite flip GOING LEFT
	if (
		horizontal_direction < 0
		#and not adjust_collision
		and not stop_state
		): handle_sprite_flip()
		
	#Sprite flip GOING RIGHT
	if (
		horizontal_direction > 0
		#and not adjust_collision
		and not stop_state
		): handle_sprite_unflip()
		

	
func _toggle_gravity2(a,b):
	#no sprite flip
	gravx = a
	gravy = b
	
	velocity = move_and_slide(velocity, Vector2(gravx,gravy))
	
	horizontal_direction = (Input.get_action_strength("ui_right") -
	Input.get_action_strength("ui_left"))
	vertical_direction = (Input.get_action_strength("ui_down") -
	Input.get_action_strength("ui_up"))
	

	velocity.x = horizontal_direction * speed
	velocity.y = vertical_direction * speed
	


func _toggle_velocity(velx, vely):
	velocity.x = velx
	velocity.y = vely

func _STAND_STILL():
	if 	(!is_zero_approx(velocity.x) and !is_zero_approx(velocity.y)):
		#print("moving")
		return false
	if 	(!is_zero_approx(velocity.x)):
		#print("moving")
		return false
	if 	(!is_zero_approx(velocity.y)):
		#print("moving")
		return false
	if 	(is_zero_approx(velocity.x) and is_zero_approx(velocity.y)):
		#print("STAND STILL")
		return true
	





################################################################################
################################################################################
#
# SIGNAL FUNCTIONS
#
################################################################################
################################################################################



func _handle_array(array_text, animation_title):
	$AnimationPlayer.play(animation_title)
	if _state_array[-1] != array_text:
		pass # remove later
#		_state_array.append(array_text) # adding to the end of our huge array
#		print(PLAYER_STATE.keys()[_state_array[-1]]) # printing the last element of the array
#		if _state_array.size() > 4:
#			_state_array.pop_front()

func handle_sprite_unflip():
		sprite_flip = false
		get_node("Sprite").set_flip_h(false)
		get_node("OpenDirDTC/OpenDirDTC").position = Vector2(3,-10)
		get_node("GroundDTC").position = Vector2(3,-9)
		get_node("CLIMBDTC").position = Vector2(4,-1)
		


		
func handle_sprite_flip():
		sprite_flip = true
		get_node("Sprite").set_flip_h(true)
		get_node("OpenDirDTC/OpenDirDTC").position = Vector2((3-6),(-10))
		get_node("GroundDTC").position = Vector2((3-6),(-9))
		get_node("CLIMBDTC").position = Vector2((4-1),(-1))
		



func handle_ClimbGO():
	allow_climbing = true
	
func handle_ClimbSTOP():
	allow_climbing = false
	climbing = false
	
func handle_OpenCollideGO():
	allow_up = true

func handle_OpenCollideSTOP():
	allow_up = false
#	if Input.is_action_pressed("ui_run"):
#		velocity.y = 0
#		running = false
#	if Input.is_action_pressed("ui_up") and running:
#		velocity.y = 0
#		running = false


func handle_OpenDirGO():
	grounded = true
	open_direction_bg_active = true
	
func handle_OpenDirSTOP():
	open_direction_bg_active = false
	grounded = false
#	if not grounded:
#		_turn_on_gravity()
#	if not open_movement:
#		gravy = -1
#		player_is_on_floor = false

func show_damage_effect():
		stop_state = true
		
		if stop_state:
			$AnimationPlayer.play("Jump_Land")
			$AllowState.start()
			velocity.y = -100
			speed = speed/10
			$AnimationPlayer2.play("Fall_Damage_Red")
			$AnimationPlayer2.queue("Fall_Damage_Flash")
			$AnimationPlayer2.queue("Animation_Reset")
			fall_damage = false
			
func _on_AllowState_timeout():
	#timer waits .68 seconds and then:
	stop_state = false
	if not stop_state:
		too_high = false
		fall_damage = false

func _start_climbing():
	if _allow_climbing() and !grounded:
		if Input.is_action_just_pressed("ui_up"):
			#print("A1")
			climbing = true
		if Input.is_action_pressed("ui_up"):
			#print("A2")
			climbing = true
		if Input.is_action_just_pressed("ui_down"):
			#print("A3")
			climbing = true
		if Input.is_action_pressed("ui_down"):
			#print("A4")
			climbing = true
		if !_allow_climbing():
			climbing = false
		if grounded and !climbing:
			climbing = false
		if current_state == PLAYER_STATE.CLIMBING_IDLING:
			climbing = true

			
			
func _active_climb():
	if allow_climbing and !grounded and not active_jumping: ################
		current_state = PLAYER_STATE.CLIMBING_IDLING
		falling = false
	if allow_climbing and climbing and grounded:
		climbing = false
		current_state = PLAYER_STATE.CLIMBING_IDLING #should this be idling?
		if Input.is_action_just_pressed("ui_up") or Input.is_action_pressed("ui_up"):
			current_state = PLAYER_STATE.CLIMBING_UP
		if Input.is_action_just_pressed("ui_down") or Input.is_action_pressed("ui_down"):
			current_state = PLAYER_STATE.CLIMBING_DOWN
			
	if !grounded and _allow_climbing():
		if Input.is_action_pressed("ui_up"):
			current_state = PLAYER_STATE.CLIMBING_UP
		if Input.is_action_pressed("ui_down"):
			current_state = PLAYER_STATE.CLIMBING_DOWN
		if Input.is_action_just_pressed("ui_up"):
			current_state = PLAYER_STATE.CLIMBING_UP
		if Input.is_action_just_pressed("ui_down"):
			current_state = PLAYER_STATE.CLIMBING_DOWN
			
		if _STAND_STILL():
			current_state = PLAYER_STATE.CLIMBING_IDLING
			#print("climbing idling _test3")
			
		if Input.is_action_just_pressed("ui_up"):
			_climb_up()
			#print("climbing up _test")
		
		if Input.is_action_just_pressed("ui_down"):
			_climb_down()
			#print("climbing down _test")
		
		if Input.is_action_just_pressed("ui_right"):
			_climb_right()
			#print("climbing right _test")
		
		if Input.is_action_just_pressed("ui_left"):
			_climb_left()
			#print("climbing left _test")
		if Input.is_action_pressed("ui_right"):
			current_state = PLAYER_STATE.CLIMBING_RIGHT
			if _STAND_STILL():
				current_state = PLAYER_STATE.CLIMBING_IDLING
		if Input.is_action_pressed("ui_left"):
			current_state = PLAYER_STATE.CLIMBING_LEFT
			if _STAND_STILL():
				current_state = PLAYER_STATE.CLIMBING_IDLING
				





