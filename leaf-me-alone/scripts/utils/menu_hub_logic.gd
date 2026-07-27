class_name MenuHubLogic
extends RefCounted
## Main Menu hub helpers (Story 7.4).


static func format_cc_header(balance: int) -> String:
	return "CC %d" % maxi(0, balance)
