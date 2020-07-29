extends StaticBody2D

const EXPLOSION_RADIUS = 2

onready var explosion_scene = preload("res://scenes/explosion/Explosion.tscn")
onready var tilemap = get_node("/root/Arena/TileMap")
onready var tile_solid_id = tilemap.tile_set.find_tile_by_name("SolidBrick")

func _ready():
	print("in Bomb.gd")
	print(tile_solid_id)
	# $AnimationPlayer.play("default")
func propagate_explosion(centerpos, propagation):
	var center_tile_pos = tilemap.world_to_map(centerpos)
	
	for i in range(1, EXPLOSION_RADIUS + 1):
		var tilepos = center_tile_pos + propagation * 1
		if tilemap.get_cellv(tilepos) != tile_solid_id:
			# Boom!
			var explosion = explosion_scene.instance()
			explosion.position = tilemap.centered_world_pos_from_tilepos(tilepos)
			get_parent().add_child(explosion)
		else:
			# Explosion was stopped by a solid brick
			break



func _on_AnimationPlayer_animation_finished(anim_name):
	# Make the bomb blow up at the end of the animation

	# First, set a center explosion at the bomb position
	var center_explosion = explosion_scene.instance()
	center_explosion.owner = owner
	center_explosion.position = position
	center_explosion.type = center_explosion.CENTER
	get_parent().add_child(center_explosion)

	# Propagate the explosion by starting where the bomb was and go
	# away from it in straight vertical and horizontal lines
	propagate_explosion(position, Vector2(0, 1))
	propagate_explosion(position, Vector2(0, -1))
	propagate_explosion(position, Vector2(1, 0))
	propagate_explosion(position, Vector2(-1, 0))

	# Finally destroy the bomb node
	queue_free()

