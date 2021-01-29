extends Node

signal newScrollContainerButton

var FocusGroup:Array
var ButtonsSections:Dictionary = {}

onready var focus_detect:Control = Control.new() # Use to detect if no button in focus
onready var _arrow: Resource = load('res://assets/images/gui/cursor_arrow.png')
onready var _hand: Resource = load('res://assets/images/gui/cursor_hand.png')
onready var _move: Resource = load('res://assets/images/gui/cursor_move.png')

func _ready()->void:
	add_child(focus_detect) #Without this it can't detect buttons in focus

	pause_mode = Node.PAUSE_MODE_PROCESS
	set_process_unhandled_key_input(true)
	GuiEvent.connect("Refocus", self, "force_focus")

	# Modificar los cursores por defecto del sistema operativo
#	Input.set_custom_mouse_cursor(_arrow, Input.CURSOR_ARROW)
#	Input.set_custom_mouse_cursor(_hand, Input.CURSOR_POINTING_HAND)
#	Input.set_custom_mouse_cursor(_move, Input.CURSOR_MOVE)

func gui_collect_focusgroup()->void:	#Workaround to get initial focus
	FocusGroup.clear()
	FocusGroup = get_tree().get_nodes_in_group("FocusGroup")
	for btn in FocusGroup: #Save references to call main buttons in sections
		var groups:Array = btn.get_groups()
		if groups.has("MainMenu"):
			ButtonsSections["MainMenu"] = btn
		if groups.has("Pause"):
			ButtonsSections["Pause"] = btn
		if groups.has("OptionsMain"):
			ButtonsSections["OptionsMain"] = btn
		if groups.has("OptionsControls"):
			ButtonsSections["OptionsControls"] = btn
		if groups.has("DialogMenu"):
			ButtonsSections["DialogMenu"] = btn
	# Para que por defecto se seleccione la primera opción de cualquier menú que
	# se abra por aquí
	if Data.get_data(Data.FORCE_FOCUS):
		force_focus()

func _unhandled_input(event: InputEvent)->void:
	if event.is_action_pressed("ui_cancel"):
		if !SectionEvent.MainMenu:			#not in main menu
			if !SectionEvent.Paused:
				SectionEvent.Paused = true
			elif !SectionEvent.Options:
				SectionEvent.Paused = false
	elif focus_detect.get_focus_owner() != null:	#There's already button in focus
		return
	elif event.is_action_pressed("ui_right"):
		GuiEvent.emit_signal("Refocus")
	elif event.is_action_pressed("ui_left"):
		GuiEvent.emit_signal("Refocus")
	elif event.is_action_pressed("ui_up"):
		GuiEvent.emit_signal("Refocus")
	elif event.is_action_pressed("ui_down"):
		GuiEvent.emit_signal("Refocus")

func force_focus():
	var btn:Button
	
	# TODO: Cambiar esta mierda por un match
	if SectionEvent.MainMenu:
		if SectionEvent.Options:
			if SectionEvent.Controls:
				btn = ButtonsSections.OptionsControls
			else:
				btn = ButtonsSections.OptionsMain
		else:
			btn = ButtonsSections.MainMenu
	else:
		if SectionEvent.Options:
			if SectionEvent.Controls:
				btn = ButtonsSections.OptionsControls
			else:
				btn = ButtonsSections.OptionsMain
		else:
			if SectionEvent.Paused:
				btn = ButtonsSections.Pause
			elif SectionEvent.in_dialog:
				btn = ButtonsSections.DialogMenu
	if btn != null:
		btn.grab_focus()
