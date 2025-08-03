extends VBoxContainer

signal arachnophobia_mode_toggled

@onready var volume_slider = $VolumeHBoxContainer/HSlider
@onready var volume_spin_box = $VolumeHBoxContainer/SpinBox

@onready var check_button_status_label = $ArachnophobiaModeHBoxContainer/CheckButtonStatusLabel

func set_volume(value):
	var music_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(music_index, linear_to_db(value / float(100)))

func _on_h_slider_value_changed(value):
	volume_spin_box.set_value_no_signal(value)
	set_volume(value)

func _on_spin_box_value_changed(value):
	volume_slider.set_value_no_signal(value)
	set_volume(value)

func _on_check_button_toggled(toggled_on):
	check_button_status_label.text = "ON" if toggled_on else "OFF"
	Managers.map_manager.bitchMode = toggled_on
