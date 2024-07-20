extends Control

@export var anouther_shop: Control
@export var buy_sound_player: AudioStreamPlayer
@onready var products_container : ItemList = $GoodsContainer

var aviable_str: String = " (" + tr("AVIABLE") + ")"

func disable():
	position.x = -400

func replace_shop():
	if position.x > 0:
		disable()
	else:
		position.x = 412
	
	if position.x == anouther_shop.position.x and position.x > 0:
		anouther_shop.disable()
		
func check_price(item_idx: int) -> int:
	var item_text : String = products_container.get_item_text(item_idx)
	
	if item_text.contains(tr("AVIABLE")):
		return -1
		
	var item_price_idx_start : int = item_text.find("(") + 1
	var item_price : String = item_text.substr(item_price_idx_start, item_text.find(" ", item_price_idx_start) - item_price_idx_start)
		
	if Data.bananas >= int(item_price):
		return int(item_price)
	else:
		return 0 
	
func buy_skin(item_idx: int, price: int):
	var item_text : String = products_container.get_item_text(item_idx)
	var item_name = item_text.substr(0, item_text.find("(")-1)
	
	Data.bananas -= price
	products_container.set_item_text(item_idx, item_name + aviable_str)
	Data.change_skin(item_name)

func buy_upgrade(item_idx: int, price: int):
	var item_text : String = products_container.get_item_text(item_idx)
	var item_name = item_text.substr(0, item_text.find("(")-1)

	var tail_name: String = tr("TAIL")
	var dash_name: String = tr("DASH")
	
	match item_name:
		tail_name:
			Data.has_tail = true
			Data.afterbuy = "tail"
		dash_name:
			Data.have_dash = true
			Data.afterbuy = "dash"
	
	products_container.set_item_text(item_idx, item_name + aviable_str)
	LevelLoader.fill_aviable_levels_array()
	Data.bananas -= price
	
func _ready():
	if name.contains("Upgrades"):
		if Data.has_tail:
			products_container.set_item_text(0, tr("TAIL") + aviable_str)
		else:
			products_container.set_item_text(0, tr("TAIL") + " (" + "500 " + tr("BANANAS") + ")")

		if Data.have_dash:
			products_container.set_item_text(1, tr("DASH") + aviable_str)
		else:
			products_container.set_item_text(1, tr("DASH") + " (" + "500 " + tr("BANANAS") + ")")

		return
		
	for i in products_container.item_count:
		var item_text: String = products_container.get_item_text(i)
		var item_name: String = item_text.substr(0, item_text.find("(")-1)

		var skins_list: Dictionary = {
			tr("SK_STANDART"): tr("AVIABLE"),
			tr("SK_BLACK"): "1000 " + tr("BANANAS"),
			tr("SK_SHADOW"): "1500 " + tr("BANANAS"),
			tr("SK_DEVIL"): "2000 " + tr("BANANAS"),
			tr("SK_CYBORG"): "3500 " + tr("BANANAS")
		}

		if Data.unlocked_skins.find(tr(item_name)) != -1:
			products_container.set_item_text(i, tr(item_name) + aviable_str)
		else:
			products_container.set_item_text(i, tr(item_name) + " (" + skins_list[tr(item_name)] + ")")

func _on_upgrades_shop_pressed():
	replace_shop() 

func _on_skins_shop_pressed():
	replace_shop()

func _on_skins_container_item_activated(index: int):
	var price = check_price(index)
	if price > 0:
		buy_skin(index, price)
		buy_sound_player.stream = load("res://Assets/Sounds/buy.mp3")
	elif price == -1:
		var item_text: String = products_container.get_item_text(index)
		Data.change_skin(item_text.substr(0, item_text.find("(")-1))
		buy_sound_player.stream = load("res://Assets/Sounds/buy.mp3")
	else:
		buy_sound_player.stream = load("res://Assets/Sounds/buy_out.mp3")
	
	buy_sound_player.play()
	
func _on_upgrades_container_item_activated(index: int):
	var price = check_price(index)
	if price > 0:
		buy_upgrade(index, price)
		buy_sound_player.stream = load("res://Assets/Sounds/buy.mp3")
	else:
		buy_sound_player.stream = load("res://Assets/Sounds/buy_out.mp3")
	
	buy_sound_player.play()
