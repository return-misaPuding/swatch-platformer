extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_player_display_time(lvl: Array, full: Array,current_lvl_number: int) -> void:
	#print("timer signal received "+str(lvl))
	var pad_lvl_sec = str(lvl[1])
	var pad_lvl_min = str(lvl[0])
	var pad_g_sec = str(full[1]) # g is global time
	var pad_g_min = str(full[0])
	if len(pad_lvl_sec) < 2:
		pad_lvl_sec = "0"+pad_lvl_sec
	if len(pad_lvl_min) < 1: # i do not expect playtimes to go over 10 minutes
		pad_lvl_min = "0"+pad_lvl_min # no need to fix the padding for that case
	if len(pad_g_sec) < 2:
		pad_g_sec = "0"+pad_g_sec
	if len(pad_g_min) < 1:
		pad_g_min = "0"+pad_g_min
	$LvlTime.text = "LVL"+str(current_lvl_number)+": "+pad_lvl_min+":"+pad_lvl_sec+"."+str(lvl[2])
	$GlobalTime.text =  pad_g_min+":"+pad_g_sec+"."+str(full[2])


func _on_player_display_death(total: int, lvl: int, ckpt: int, show_ckpt: bool) -> void:
	if !show_ckpt:
		$Ckpt.show() # i entered the boolean wrong in my signal emit events
		$CkptSprite.show()
	else:
		$Ckpt.hide()
		$CkptSprite.hide()
	$Total.text = str(total)
	$Level.text = str(lvl)
	$Ckpt.text = str(ckpt)
