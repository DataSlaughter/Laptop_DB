extends Node2D


signal ClimbGO
signal ClimbSTOP

signal OpenDirGO
signal OpenDirSTOP

signal OpenCollideGO
signal OpenCollideSTOP





# Called when the node enters the scene tree for the first time.
func _ready():


	#ADD COLLISION DETECTION TO SEND GROUNDED SIGNAL
	
	pass


func _process(_delta):
	pass




		
		
func _on_CLIMBDTC_area_entered(area):
	if area.is_in_group("Climb"):
		emit_signal("ClimbGO")
	
	if area.is_in_group("OpenDir"):
		emit_signal("OpenDirGO")
		
	
func _on_OpenDirDTC_area_entered(area):
	if area.is_in_group("OpenDir"):
		emit_signal("OpenCollideGO")
	
func _on_CLIMBDTC_area_exited(area):
	if area.is_in_group("Climb"):
		emit_signal("ClimbSTOP")
		
	if area.is_in_group("OpenDir"):
		emit_signal("OpenDirSTOP")


#Exit OpenDir
func _on_OpenDirDTC_area_exited(area):
	if area.is_in_group("OpenDir"):
		emit_signal("OpenCollideSTOP")



#
#
#


