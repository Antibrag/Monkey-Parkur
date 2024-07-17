extends VSplitContainer

@onready var upgrades_shop_button: Button = $UpgradesShop
@onready var skins_shop_button: Button = $SkinsShop

const UPGRADES_BUTTON_TEXT: String = "Улучшения"
const SKINS_BUTTON_TEXT: String = "Скины"

func enable():
	upgrades_shop_button.disabled = false
	skins_shop_button.disabled = false
	
func disable():
	upgrades_shop_button.disabled = true
	skins_shop_button.disabled = true

func put_text_to_button(button: Button, text_to_put: String):
	$ButtonTextCleaner.stop()
	button.text = ""
	for i in text_to_put:
		button.text = button.text + i
		await get_tree().create_timer(0.01).timeout

func del_button_text(button: Button):
	var text_length: int = button.text.length()
	for i in text_length:
		button.text = button.text.left(button.text.length()-1)
		await get_tree().create_timer(0.01).timeout
	button.text = ""
	$ButtonTextCleaner.start()

func _on_upgrades_shop_mouse_entered():
	put_text_to_button(upgrades_shop_button, UPGRADES_BUTTON_TEXT)

func _on_upgrades_shop_mouse_exited():
	del_button_text(upgrades_shop_button) 

func _on_skins_shop_mouse_entered():
	put_text_to_button(skins_shop_button, SKINS_BUTTON_TEXT) 

func _on_skins_shop_mouse_exited():
	del_button_text(skins_shop_button) 

func _on_button_text_cleaner_timeout():
	upgrades_shop_button.text = ""
	skins_shop_button.text = ""
