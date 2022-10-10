retailersIds = ->
  $('input[data-retailer-id]').map (index, element) ->
    element.dataset.retailerId

changeHandlers =
  delivery_zones_select: (event) ->
    deliveryZoneId = $(event.target).val()
    retailerSelect = $ '#retailers_select'
    retailers = retailerSelect.data "delivery-zone-#{deliveryZoneId}"
    html = '<option value=""></option>'
    for retailer in retailers
      disabled = if retailer.id.toString() in retailersIds() then 'disabled' else ''
      html += "<option #{disabled} value=\"#{retailer.id}\">#{retailer.company_name}</option>"
    retailerSelect.html html

  retailers_select: (event) ->
    select = $(event.target)
    retailerId = select.val()
    if retailerId
      option = select.find("option[value='#{retailerId}']")
      retailerName = option.text()
      option.attr 'disabled', true
      $('ul#retailers_list').append "<li>
        <a href='#' data-retailer-id='#{retailerId}'>×</a>
        #{retailerName}
      </li>"
      $('#retailers_hidden_fields').append "<input type='hidden'
        name='promotion_code[retailer_ids][]'
        value='#{retailerId}'
        data-retailer-id='#{retailerId}'
      >"
      select.val ''

handleInputEvents = (retailersInput) ->
  retailersInput.on 'change', 'select', (event) ->
    changeHandlers[event.target.id] event

  retailersInput.on 'click', 'a[data-retailer-id]', (event) ->
    event.preventDefault()
    $('input[data-retailer-id="' + @dataset.retailerId + '"]').remove()
    $("select#retailers_select option[value='#{@dataset.retailerId}']").removeAttr('disabled')
    $(@).parent('li').remove()

$ ->
  retailersInput = $ '#retailers_admin_select'
  handleInputEvents(retailersInput) if retailersInput[0]
