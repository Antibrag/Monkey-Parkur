extends CanvasLayer

@onready var distance_label: Label = $DistanceLabel
@onready var banana_label: Label = $BananaLabel
@onready var max_distance_label: Label = $MaxDistanceLabel
@onready var level_name_label: Label = $LevelNameLabel
@onready var level_author_label: Label = $LevelAuthorLabel
@onready var level_requires_label: Label = $LevelRequiresLabel

func show_level_bar(level_index: int, author_name: StringName, requires: String):
	level_name_label.text = "Уровень " + str(level_index)
	level_author_label.text = "\tАвтор: " + author_name
	level_requires_label.text = "Требуется: " + requires
	
	while level_name_label.modulate.a < 1:
		level_name_label.modulate.a += 0.01
		level_author_label.modulate.a += 0.01
		level_requires_label.modulate.a += 0.01
		await get_tree().create_timer(0.01).timeout
	
	await get_tree().create_timer(2).timeout
	
	while level_name_label.modulate.a > 0:
		level_name_label.modulate.a -= 0.01
		level_author_label.modulate.a -= 0.01
		level_requires_label.modulate.a -= 0.01
		await get_tree().create_timer(0.01).timeout

func hide_distance_label():
	distance_label.hide()
	
func hide_banana_label():
	banana_label.hide()
	
func show_distance_label():
	distance_label.show()
	
func show_banana_label():
	banana_label.show()

func _process(_delta):
	distance_label.text = "Дистанция: " + str(Data.distance) + "м"
	max_distance_label.text = "Предыдущий лучший результат: " + str(Data.max_distance) + "м"
	banana_label.text = "Бананов: " + str(Data.bananas) + "шт"
	
