extends Area2D
signal portal_trigger

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("portal")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	print("portal body encounter "+str(body))
	if body.is_in_group("playergroup"):
		print("!! player in portal")
		portal_trigger.emit()
