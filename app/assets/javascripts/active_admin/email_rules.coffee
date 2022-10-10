handleInputEvents = (selectInput) ->
  if selectInput.val() == 'Abandon Basket'
    $('#email_rule_send_time_input').hide()
    $('#email_rule_promotion_code_id_input').hide()
  else
    $('#email_rule_send_time_input').show()
    $('#email_rule_promotion_code_id_input').show()

$ ->
  categoryInput = $ '#email_rule_category'
  handleInputEvents($(categoryInput))
  categoryInput.on 'change', (event) ->
    event.preventDefault()
    select = $(event.target)
    handleInputEvents(select)

