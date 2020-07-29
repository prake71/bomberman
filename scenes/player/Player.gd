extends KinematicBody2D

onready var bomb_scene = preload("res://scenes/bomb/Bomb.tscn")
onready var animation = get_node("AnimationPlayer")
onready var tilemap = get_node("/root/Arena/TileMap")

onready var drop_bomb_cooldown = get_node("DropBombCoolDownTimer")

# how fast the player moves
const WALK_SPEED = 200
# is player dead?
var dead = false
var direction = Vector2()
# which animation to play 
var current_animation = "idle"
var can_drop_bomb = true


func _ready():
	
	print(tilemap)	
	pass # Replace with function body.


func _physics_process(delta):
	# nothing to do when player dead

	if not dead:
		# check cursor input (up, down, left, right) 
		if (Input.is_action_pressed("ui_up")):
			direction.y = - WALK_SPEED
		elif (Input.is_action_pressed("ui_down")):
			direction.y = WALK_SPEED
		else:
			direction.y = 0
	
		if (Input.is_action_pressed("ui_left")):
			direction.x = -WALK_SPEED
		elif (Input.is_action_pressed("ui_right")):
			direction.x = WALK_SPEED
		else: 
			direction.x = 0
	# Moves the body along a vector. If the body  collides with another, 
	# it will slide along the other body rather than stop immediately. 
	move_and_slide(direction)
	
	# update rotation
	rotation = atan2(direction.y, direction.x)
	_update_animation(direction)
	
func _update_animation(direction):
	var new_animation = "idle"
	if direction:
		new_animation = "walking"
	if new_animation != current_animation:
		animation.play(new_animation)
		current_animation = new_animation
	
	
func _process(delta):
	if dead:
		return
	# allow player to plant bombs
	if Input.is_action_just_pressed("ui_select") and can_drop_bomb:
		drop_bomb(tilemap.centered_world_pos(position))
		can_drop_bomb = false
		drop_bomb_cooldown.start()
		
		
sync func drop_bomb(pos): 
	var bomb = bomb_scene.instance()
	bomb.position = pos
	# To keep track of the scene hierarchy (especially when instancing 
	# scenes into other scenes), an „owner“ can be set for the node 
	# with the owner property. This keeps track of who instanced what. 
	# This is mostly useful when writing editors and tools, though.
	bomb.owner = self
	get_node("/root/Arena").add_child(bomb)
		
func _on_DropBombCoolDownTimer_timeout():
	can_drop_bomb = true
