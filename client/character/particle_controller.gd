class_name ParticleController
# Controls particle and stuff like that

var sun_particles = ParticleManager.get_particle_scene("sun").instantiate()
var moon_particles = ParticleManager.get_particle_scene("moon").instantiate()
var speed_particles = ParticleManager.get_particle_scene("speed_burst").instantiate()
var invincibility_particles = ParticleManager.get_particle_scene("invincibility").instantiate()


func _init(_character: Character):
	_character.particles.add_child(sun_particles)
	sun_particles.position.y = -106.0
	_character.sun_particles = sun_particles
	_character.particles.add_child(moon_particles)
	moon_particles.position.y = -106.0
	_character.moon_particles = moon_particles
	_character.particles.add_child(speed_particles)
	speed_particles.position.y = -106.0
	_character.speed_particles = speed_particles
	_character.particles.add_child(invincibility_particles)
	invincibility_particles.position.y = -106.0
	_character.invincibility_particles = invincibility_particles
