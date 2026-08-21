class_name ListCache

static var cache: Dictionary = {}
var expire_time: int = 0
var total_results: int = 0
var list: Array = []

#Time.get_ticks_msec()


static func get_from_cache(cache_name: String, start_from: int, total: int) -> Dictionary:
	var count: int = 0
	var current_cache = null
	var selected_cache = null
	var seek_cache = cache.get(cache_name)
	var cache_info = {}
	var current_time = Time.get_ticks_msec()
	var seek_to: int = start_from + total
	var cache_list: Array = []
	var cache_is_valid: bool = true
	if seek_cache != null:
		count = start_from
		while count < seek_to:
			current_cache = seek_cache.list[count]
			if current_cache == null or current_cache.expire_time <= current_time:
				cache_is_valid = false
				break
			if !current_cache.is_empty():
				cache_list.push_back(current_cache)
			count += 1
		if cache_is_valid:
			selected_cache = {}
			selected_cache["list"] = cache_list
			selected_cache["total_results"] = seek_cache.total_results
			cache_info = selected_cache
	return cache_info


static func delete_entire_cache():
	cache = {}


static func delete_cache(cache_name: String):
	cache.erase(cache_name)


static func save_to_cache(cache_name: String, time_before_expire: int, start_from: int, total: int, tot_results: int, cache_list: Array):
	var current_cache = null
	var selected_cache = cache.get(cache_name)
	if selected_cache == null:
		selected_cache = ListCache.new()
		cache[cache_name] = selected_cache
	var new_expire_time = Time.get_ticks_msec() + time_before_expire
	var seek_to: int = start_from + total
	var count: int = start_from
	while count < seek_to:
		current_cache = cache_list.get(count - start_from)
		if current_cache == null:
			current_cache = {}
		current_cache["expire_time"] = new_expire_time
		if selected_cache.list.size() < count + 1:
			selected_cache.list.resize(count + 1)
		selected_cache.list[count] = current_cache
		selected_cache.expire_time = new_expire_time
		count += 1
	selected_cache.total_results = tot_results


static func get_cache(cache_name: String) -> Array:
	var loc_2 = []
	var loc_3 = cache.get(cache_name)
	if loc_3 != null:
		loc_2 = loc_3.list
	return loc_2


static func update_total_results(cache_name: String, tot_results: int):
	var loc_3 = cache.get(cache_name)
	if loc_3 != null:
		loc_3.total_results = tot_results


func is_expired() -> bool:
	return Time.get_ticks_msec() > expire_time
