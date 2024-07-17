extends Control

@export var anouther_shop: Control
@onready var products_container : ItemList = $GoodsContainer

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
	
	if item_text.contains("Имеется"):
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
	products_container.set_item_text(item_idx, item_name + " (Имеется)")
	Data.change_skin(item_name)

func buy_upgrade(item_idx: int, price: int):
	var item_text : String = products_container.get_item_text(item_idx)
	var item_name = item_text.substr(0, item_text.find("(")-1)
	
	match item_name:
		"Крепкий хвост":
			Data.has_tail = true
			Data.afterbuy = "tail"
		"Рывок":
			Data.have_dash = true
			Data.afterbuy = "dash"
	
	products_container.set_item_text(item_idx, item_name + " (Имеется)")
	LevelLoader.fill_aviable_levels_array()
	Data.bananas -= price
	
func _ready():
	if name.contains("Upgrades"):
		if Data.has_tail:
			products_container.set_item_text(0, "Крепкий хвост" + " (Имеется)")
		if Data.have_dash:
			products_container.set_item_text(1, "Рывок" + " (Имеется)")
		return
		
	for i in products_container.item_count:
		var item_text: String = products_container.get_item_text(i)
		var item_name: String = item_text.substr(0, item_text.find("(")-1)
		if Data.unlocked_skins.find(item_name) != -1:
			products_container.set_item_text(i, item_name + " (Имеется)")

func _on_upgrades_shop_pressed():
	replace_shop() 

func _on_skins_shop_pressed():
	replace_shop()

func _on_skins_container_item_activated(index: int):
	var price = check_price(index)
	if price > 0:
		buy_skin(index, price)
	elif price == -1:
		var item_text: String = products_container.get_item_text(index)
		Data.change_skin(item_text.substr(0, item_text.find("(")-1))
	
func _on_upgrades_container_item_activated(index: int):
	var price = check_price(index)
	if price > 0:
		buy_upgrade(index, price)
