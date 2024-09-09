extends Area2D

@export var player: CharacterBody2D

var triggered: bool = false

var trigger_in: ScrollTrigger

#func _process(_delta):
	#if !player: return
#
	#for trigger in get_overlapping_areas():
		#if (player.state == player.STATES.AIR and player.velocity.y > 0 and (trigger.scroll_direction == 3)) and !triggered or \
			#(player.state == player.STATES.CLIMB and player.velocity.y > 0 and (trigger.scroll_direction == 3)) and !triggered:
			#triggered = true
			#print("AAAA")
			#trigger.scroll_triggered()
		#if (player.state == player.STATES.CLIMB and player.velocity.y < 0) and (trigger.scroll_direction == 2) and !triggered:
			#triggered = true
			#trigger.scroll_triggered()
#
		#if (trigger.scroll_direction == 0 or trigger.scroll_direction == 1):
			#triggered = true
			#trigger.scroll_triggered()
#
		#triggered = false
