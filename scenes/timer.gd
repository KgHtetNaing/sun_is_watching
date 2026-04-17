extends Timer

func ready():
	add_to_group("main_timer")

func stop_the_clock():
	self.stop()
	print ("Main timer is stopped")
