extends Control


func _ready() -> void:
	if ContentRegistry.is_loaded():
		$Label.text = tr("Leaf Me Alone — Bootstrap OK")
	else:
		$Label.text = tr("Leaf Me Alone — Content load FAILED")
		push_error("Bootstrap: ContentRegistry failed to load critical content")
