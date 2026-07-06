extends Node3D


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F:
			WaveManager.start_run()
		elif event.keycode == KEY_R:
			get_tree().reload_current_scene()
		elif event.keycode == KEY_8:
			# debug, skip to boss wave
			WaveManager.current_wave_index = 6  # next call increments to 7 (wave 8)
			# Clear alive enemies
			for e in WaveManager.alive_enemies:
				if is_instance_valid(e):
					e.queue_free()
			WaveManager.alive_enemies.clear()
			WaveManager._wave_clear_announced = false
			WaveManager._start_next_wave()
