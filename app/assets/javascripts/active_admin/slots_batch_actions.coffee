handleInputEvents = (selectInput) ->
  if selectInput.val() == '2'
    $('#delivery_slot_retailer_delivery_zone_id_input').hide()
  else
    $('#delivery_slot_retailer_delivery_zone_id_input').show()

$ ->
  retailerServiceId = $ '#delivery_slot_retailer_service_id'
  handleInputEvents($(retailerServiceId))
  retailerServiceId.on 'change', (event) ->
    event.preventDefault()
    select = $(event.target)
    handleInputEvents(select)
