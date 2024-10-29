extends Node2D

# Directions
# 0 - * - 6
# 1-//|\\-5
#   2 3 4

const DOWN : Vector2 = Vector2(0.0, 1.0)

var d_index   : int: set = d_index_set
var direction : Vector2: set = direction_set
var drag      : float: get = drag_get
var speed     : float: get = speed_get
var force     : float
var velocity  : Vector2

var braking   : bool

@export var free_move      : bool = true
@export var running_drag   : float = 1.48
@export var braking_drag   : float = 4.5
@export var side_redirect  : float = 22.0
@export var mass           : float = 1.0
@export var downhill_force : float = 500.0

const SPRITE_LOOKUP := [[3, true], [2, true], [1, true], [0, false], 
						[1, false], [2, false], [3, false]]
						
const DIRECTION_LOOKUP := [Vector2(-1, 0), Vector2(-.867, .5), Vector2(-.5, .867), Vector2(0.0, 1.0),
						   Vector2(.5, .867), Vector2(.867, .5), Vector2(1, 0)]

var framePreviousColide

func _process(delta):
	if Globals.giroscope == true && Globals.gameisPlaying == true:
		self.handle_direction(Vector2(Input.get_accelerometer().normalized().x * 800,-Input.get_accelerometer().normalized().y * 800 ) )
	pass
	#print(Vector2(Input.get_accelerometer().normalized().x * 800,Input.get_accelerometer().normalized().y * 800 ))
	
	

func _ready() -> void:
	self.direction = Vector2(1.0, 0.0)
	self.velocity = Vector2(0.0, 0.0)
	self.light_mask = 1
	self.visibility_layer = 1
	self.z_index = 1
	pass

func _physics_process(delta:float) -> void:
	var accel := self.force / self.mass
	self.velocity = self.velocity + ((self.direction*accel) - (self.drag*self.velocity)) * delta
	self.translate(self.velocity * delta)
	
	# Side friction
	var vn := self.velocity.normalized().dot(direction)
	var amount_to_redirect := (self.side_redirect*delta)
	var penalized_vel := self.velocity * (1.0 - vn)
	var pmagnitude := (penalized_vel*amount_to_redirect).length()
	var redirected := (penalized_vel * (1.0-amount_to_redirect)) + (direction*pmagnitude)
	
	self.velocity = (self.velocity * vn) + redirected
	var velocityms = self.velocity.length()/100
	Globals.updateVelocity(velocityms)
	if velocityms > 5:
		Globals.addPoints(5)
	#print(self.velocity)
	
func _input(event:InputEvent) -> void:
	if Globals.giroscope == false && Globals.gameisPlaying == true:
		if event is InputEventMouseMotion:		
			self.handle_direction(get_global_mouse_position() - self.global_position)

# Rotate by the given angle in radians. Positive = CW
#func change_direction(dangle:float) -> void:
#	self.direction = self.direction.rotated(dangle)

func handle_direction(dir:Vector2) -> void:
	dir = dir.normalized()
	self.d_index = self.calc_index(dir)
	if free_move:
		self.direction = dir
	else:
		self.direction = DIRECTION_LOOKUP[self.d_index]

func calc_index(dir:Vector2) -> int:
	var i := 3
	if dir.y < .259: i = 6
	elif dir.y < .708: i = 5
	elif dir.y < .966: i = 4
	if (dir.x < 0) and not (i == 3): 
		i = 3 - (i - 3)
	return i

# Input should be normalized
func direction_set(value:Vector2) -> void:
	self.braking = false
	if value.y <= 0:
		value.y = 0
		if value.x == 0: value.x = 1.0 # Make sure it's not all 0
		self.braking = true
	direction = value
	self.force = direction.dot(DOWN) * downhill_force
	
func d_index_set(value:int) -> void:
	var old := d_index
	d_index = value
	if old != value: self.calc_sprite()

func calc_sprite() -> void:
	var s = SPRITE_LOOKUP[self.d_index]
	$Area2D/AnimatedSprite2D.frame = s[0]
	$Area2D/AnimatedSprite2D.flip_h = s[1]

func drag_get() -> float:
	if self.braking: return self.braking_drag
	return self.running_drag

func speed_get() -> float:	
	return self.velocity.length() / 16.0


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.name == "RockArea":
		Globals.addCollisions()
		downhill_force = 500.0
		self.velocity = Vector2( 10, 10 )
		self.direction = Vector2(1.0, 0.0)
		framePreviousColide = $Area2D/AnimatedSprite2D.frame
		$Area2D/AnimatedSprite2D.frame = [4][0]
		$Timer.start()		
	elif area.name == "BigBumpArea":
		self.velocity = Vector2( 1000, 1000 )
	elif area.name == "SmallTreeArea" or area.name == "BigTreeArea":
		Globals.addCollisions()
		downhill_force = 500.0
		self.velocity = Vector2( 0, 0 )
		self.direction = Vector2(1.0, 0.0)
		framePreviousColide = $Area2D/AnimatedSprite2D.frame
		$Area2D/AnimatedSprite2D.frame = [4][0]
		$Timer.start()
	elif area.name =="LiftPoleArea":
		Globals.addCollisions()
		downhill_force = 500.0
		self.velocity = Vector2( 0, 0 )
		self.direction = Vector2(1.0, 0.0)
		framePreviousColide = $Area2D/AnimatedSprite2D.frame		
		$Area2D/AnimatedSprite2D.frame = [4][0]
		$Timer.start()
	elif area.name =="RoughArea" or area.name == "SmallBumpArea":
		downhill_force = 500.0
		self.velocity = Vector2( 500, 500 )
	elif area.name == "SunwebLogo":
		Globals.addPoints(1)
		area.get_parent().queue_free()
	print(area.name)
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	$Timer.stop()
	$Area2D/AnimatedSprite2D.frame = framePreviousColide
	pass # Replace with function body.


func _on_time_speed_up_timeout() -> void:
	downhill_force += 100
	pass # Replace with function body.

func stopPlayer() -> void:
	self.velocity = Vector2( 0, 0 )
	self.direction = Vector2(1.0, 0.0)
	
