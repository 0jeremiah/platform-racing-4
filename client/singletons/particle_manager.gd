extends Node
## Manages loading particles at the start so we don't lag getting particles.
## Also contains particles to grab, maybe custom particles too i dont know.

var sun_particle = preload("res://particles/sunparticles.tscn")
var sun_process_material = preload("res://particles/sunparticles.tres")
var moon_particle = preload("res://particles/moonparticles.tscn")
var moon_process_material = preload("res://particles/moonparticles.tres")
var speed_burst_particle = preload("res://particles/speedparticles.tscn")
var speed_burst_process_material = preload("res://particles/speedparticles.tres")
var invincibility_particle = preload("res://particles/invincibilityparticles.tscn")
var invincibility_process_material = preload("res://particles/invincibilityparticles.tres")
var smoke_particle = preload("res://particles/smokeparticles.tscn")
var smoke_process_material = preload("res://particles/smokeparticles.tres")
var particle_list = {
	"sun": {
		"particle": sun_particle,
		"process_material": sun_process_material
		},
	"moon": {
		"particle": moon_particle,
		"process_material": moon_process_material
		},
	"speed_burst": {
		"particle": speed_burst_particle,
		"process_material": speed_burst_process_material
		},
	"invincibility": {
		"particle": invincibility_particle,
		"process_material": invincibility_process_material
		},
	"smoke": {
		"particle": smoke_particle,
		"process_material": smoke_process_material
		}
	}
var custom_particle_list = {}


func init_particles() -> void:
	if get_node("Particles"):
		for child in get_node("Particles").get_children():
			child.free()
	var particle_holder = Node.new()
	particle_holder.name = "Particles"
	add_child(particle_holder)
	for particle in particle_list:
		var particle_node = GPUParticles2D.new()
		particle_node.process_material = particle_list[particle].process_material
		particle_node.one_shot = true
		particle_node.self_modulate = Color(1.0, 1.0, 1.0 , 0.0)
		particle_node.emitting = true
		particle_holder.add_child(particle_node)


func init_custom_particles() -> void:
	if get_node("CustomParticles"):
		for child in get_node("CustomParticles").get_children():
			child.free()
	var custom_particle_holder = Node.new()
	custom_particle_holder.name = "CustomParticles"
	add_child(custom_particle_holder)
	for custom_particle in custom_particle_list:
		var custom_particle_node = GPUParticles2D.new()
		custom_particle_node.process_material = custom_particle_list[custom_particle].process_material
		custom_particle_node.one_shot = true
		custom_particle_node.self_modulate = Color(1.0, 1.0, 1.0 , 0.0)
		custom_particle_node.emitting = true
		custom_particle_holder.add_child(custom_particle_node)


func get_particle_scene(particle_name: String) -> PackedScene:
	if particle_list.has(particle_name) and particle_list[particle_name].has("particle"):
		return particle_list[particle_name].particle
	else:
		return null


func get_process_material(particle_name: String) -> ParticleProcessMaterial:
	if particle_list.has(particle_name) and particle_list[particle_name].has("process_material"):
		return particle_list[particle_name].process_material
	else:
		return null


func add_custom_particle(custom_particle_name: String, custom_particle: ParticleProcessMaterial):
	if custom_particle_list.has(custom_particle_name):
		custom_particle_list.custom_particle_name = custom_particle
	else:
		custom_particle_list.get_or_add(custom_particle_name, custom_particle)


func delete_custom_particle(custom_particle_name: String, custom_particle: ParticleProcessMaterial):
	if custom_particle_list.has(custom_particle_name):
		custom_particle_list.erase(custom_particle_list)


func import_custom_particles(new_custom_particles: Dictionary):
	custom_particle_list = new_custom_particles.duplicate(true)


func export_custom_particles() -> Dictionary:
	return custom_particle_list.duplicate(true)
