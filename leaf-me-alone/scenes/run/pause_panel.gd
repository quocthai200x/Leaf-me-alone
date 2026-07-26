extends Control
## Greybox pause prep panel shell — visibility controlled by RunRoot.


func _ready() -> void:
	refresh_dogecoin()


func refresh_dogecoin() -> void:
	%DogecoinValue.text = str(RunManager.run_state.dogecoin)
