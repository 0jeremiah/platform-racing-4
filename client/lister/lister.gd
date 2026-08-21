extends Control
class_name Lister

@onready var lister_bg = $ListerBG
@onready var no_results_found_text = $NoResultsFoundText
@onready var loading_text = $LoadingText
@onready var pagination = $Pagination
@onready var list_container = $ListContainer

static var pagination_memory: Dictionary = {}
var count: int
var page: int = 1
var pages: int = 0
var lister_width: float = 250.0
var lister_height: float = 250.0
var cache_slug: String = ""
var cache_seconds: int = 60
var lister_columns: int = 1
var lister_h_separation: int = 5
var lister_v_separation: int = 5
var starting_count: int
var pagination_slug: String = ""
var total_results: int
var results_per_page: int = 7
var list: Array = []


func _ready() -> void:
	pagination.init(1, 0, 3, true)
	pagination.set_pages.connect(pages_changed)
	pagination.set_page.connect(select_page)
	pagination.set_align("right")
	pagination.update_display()
	list_container.columns = lister_columns
	list_container.add_theme_constant_override("h_separation", lister_h_separation)
	list_container.add_theme_constant_override("v_separation", lister_v_separation)
	pagination.visible = true
	lister_bg.visible = true
	list_container.visible = true


func _process(_delta: float):
	pagination.position.x = list_container.position.x + list_container.size.x
	list_container.size = Vector2(lister_width, lister_height)
	list_container.position = Vector2(0.0, (pagination.holder.size.y + pagination.holder.position.y) + 10.0)
	lister_bg.size = list_container.size
	lister_bg.position = list_container.position
	no_results_found_text.position = Vector2(list_container.position.x + ((list_container.size.x - no_results_found_text.size.x) / 2), list_container.position.y + ((list_container.size.y - no_results_found_text.size.y) / 2))
	loading_text.position = Vector2(list_container.position.x + ((list_container.size.x - loading_text.size.x) / 2), list_container.position.y + ((list_container.size.y - loading_text.size.y) / 2))
	size = Vector2(list_container.size.x, list_container.size.y + list_container.position.y)


func display_list(list_array: Array):
	loading_text.visible = false
	no_results_found_text.visible = false
	if list_array.is_empty():
		no_results_found_text.visible = true


func set_total_results(new_total_results: int):
	total_results = new_total_results
	update_pages()
	if cache_slug != "" and cache_seconds > 0:
		ListCache.update_total_results(cache_slug, total_results)
	display_list(list)


func set_columns(new_columns: int):
	lister_columns = new_columns
	list_container.columns = lister_columns
	display_list(list)


func select_page(new_page: int):
	set_page(new_page)


func set_list(new_list: Array):
	if cache_slug != null and cache_seconds > 0:
		ListCache.save_to_cache(cache_slug, cache_seconds, starting_count, count, total_results, new_list)
	display_list(new_list)


func set_lister_width(new_lister_width: int):
	lister_width = new_lister_width
	list_container.size.x = lister_width


func set_lister_height(new_lister_height: int):
	lister_height = new_lister_height
	list_container.size.y = lister_height


func set_lister_h_separation(new_h_separation: int):
	lister_h_separation = new_h_separation
	list_container.add_theme_constant_override("h_separation", lister_h_separation)


func set_lister_v_separation(new_v_separation: int):
	lister_v_separation = new_v_separation
	list_container.add_theme_constant_override("v_separation", lister_v_separation)


func set_page(new_page: int):
	page = clamp(new_page, 1, pages)
	starting_count = (page - 1) * results_per_page
	count = results_per_page
	pagination_memory[pagination_slug] = page
	pagination._set_page(page)
	display_list(list)


func pages_changed(new_page: int):
	pagination._set_page(new_page)
	display_list(list)


func get_last_remembered_page() -> int:
	var remembered_page: int = 1
	if pagination_memory.get(pagination_slug) != null:
		remembered_page = int(pagination_memory[pagination_slug])
	return remembered_page


func refresh():
	if cache_slug != "":
		ListCache.delete_cache(cache_slug)
	set_page(page)


func request_results_from_server(param1: int, param2: int):
	pass


func request_results(param1: int, param2: int):
	var loc_3 = ListCache.get_from_cache(cache_slug, param1, param2)
	if !loc_3.is_empty():
		set_total_results(loc_3.total_results)
		display_list(loc_3.list)
	else:
		pass
		request_results_from_server(param1, param2)


func set_results_per_page(new_results_per_page: int):
	results_per_page = new_results_per_page
	update_pages()
	set_page(page)


func update_pages():
	var float_pages = float(total_results) / float(results_per_page)
	pages = ceil(float_pages)
	if pagination:
		pagination._set_pages(pages)
