extends Control
## Non-blocking tutorial callout — dismiss driven by TutorialSystem.


func show_prompt(text: String) -> void:
	%PromptLabel.text = tr(text)
	visible = true


func hide_prompt() -> void:
	visible = false
