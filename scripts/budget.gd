extends Control

@onready var expenses = $TabContainer/Overview/ExpensePanel/VBoxContainer
@onready var transactions = $TabContainer/Overview/TransactionPanel/VBoxContainer
@onready var avail_cash = $TabContainer/Overview/GridContainer/AvCashVal
@onready var month_exp = $TabContainer/Overview/GridContainer/MonthExpVal
@onready var month_inc = $TabContainer/Overview/GridContainer/MonthIncVal
@onready var month_net = $TabContainer/Overview/GridContainer/NetMonthVal

var needs_update = true

func _ready():
	pass

func _process(_delta):
	if needs_update and visible:
		needs_update = false
		_update_view()
		
func _on_money_updated():
	needs_update = true

func _update_view():
	for node in expenses.get_children():
		if node is RichTextLabel:
			node.queue_free()
	for node in transactions.get_children():
		if node is RichTextLabel:
			node.queue_free()
	
	var income = 0
	var expen = 0
	
	for expense in Global.savegame.recurring_expenses:
		var amount = expense.amount
		if amount < 0:
			expen -= amount
		else:
			income += amount
		var node = RichTextLabel.new()
		node.bbcode_enabled = true
		node.fit_content = true
		node.append_text(_make_money_string(expense.amount, expense.title))
		expenses.add_child(node)
	for transaction in Global.savegame.transactions:
		var node = RichTextLabel.new()
		node.bbcode_enabled = true
		node.fit_content = true
		node.append_text(_make_money_string(transaction.amount, transaction.title))
		transactions.add_child(node)
	
	month_exp.clear()
	month_exp.append_text("[color=red]-$%s[/color]" % [comma_sep(expen)])
	month_inc.clear()
	month_inc.append_text("[color=green]+$%s[/color]" % [comma_sep(income)])
	month_net.clear()
	month_net.append_text(_make_money_string(income - expen, ""))
	avail_cash.clear()
	avail_cash.append_text(_make_money_string(Global.savegame.cash, ""))


func _make_money_string(amount: int, title: String) -> String:
	if amount < 0:
		return "[color=red]-$%s[/color] %s" % [comma_sep(-1 * amount), title]
	else:
		return "[color=green]+$%s[/color] %s" % [comma_sep(amount), title]


func comma_sep(n: int) -> String:
	var result := ""
	var i: int = abs(n)
	while i > 999:
		result = ",%03d%s" % [i % 1000, result]
		i /= 1000
	
	return "%s%s%s" % ["-" if n < 0 else "", i, result]
