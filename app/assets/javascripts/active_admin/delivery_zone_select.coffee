DeliveryZoneSelect =
  locationsIds: ->
    $('input[data-delivery-zone-id-id]').map (index, element) ->
      element.dataset.locationId

  delivery_zone_select: (event) ->
    select = $(event.target)
    deliveryZoneId = select.val()
    if deliveryZoneId
      option = select.find("option[value='#{deliveryZoneId}']")
      deliveryZoneName = option.text()
      option.attr 'disabled', true
      $('ul#delivery_zone_list').append "<li>
        <a href='#' data-delivery-zone-id='#{locationId}'>×</a>
        #{deliveryZoneName}
      </li>"
      $('#delivery_zones_hidden_fields').append "<input type='hidden'
        name='retailer[delivery_zone_ids][]'
        value='#{deliveryZoneId}'
        data-delivery-zone-id='#{deliveryZoneId}'
      >"
      select.val ''

  handleInputEvents: (locationsInput) ->
    locationsInput.on 'change', (event) ->
      select = $(event.target)
      console.log select.val()
      deliveryZoneId = select.val()
      if deliveryZoneId
        option = select.find("option[value='#{deliveryZoneId}']")
        deliveryZoneName = option.text()
        option.attr 'disabled', true
        $('ul#delivery_zones_list').append "<li>
          <a href='#' data-delivery-zone-id='#{deliveryZoneId}'>×</a>
          #{deliveryZoneName}
        </li>"
        $('#delivery_zones_hidden_fields').append "<input type='hidden'
          name='retailer[delivery_zone_ids][]'
          value='#{deliveryZoneId}'
          data-delivery-zone-id='#{deliveryZoneId}'
        >"
        select.val ''

    locationsInput.on 'click', 'a[data-delivery-zone-id]', (event) ->
      event.preventDefault()
      $('input[data-delivery-zone-id="' + @dataset.deliveryZoneId + '"]').remove()
      $("select#delivery_zone_select option[value='#{@dataset.deliveryZoneId}']").removeAttr('disabled')
      $(@).parent('li').remove()

$ ->
  locationsInput = $ '#delivery_zone_admin_select'
  DeliveryZoneSelect.handleInputEvents(locationsInput) if locationsInput[0]
