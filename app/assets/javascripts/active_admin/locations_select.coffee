locationsIds = ->
  $('input[data-location-id]').map (index, element) ->
    element.dataset.locationId

changeHandlers =
  cities_select: (event) ->
    cityId = $(event.target).val()
    locationSelect = $ '#locations_select'
    locations = locationSelect.data "city-#{cityId}"
    html = '<option value=""></option>'
    for location in locations
      disabled = if location.id.toString() in locationsIds() then 'disabled' else ''
      html += "<option #{disabled} value=\"#{location.id}\">#{location.name}</option>"
    locationSelect.html html

  locations_select: (event) ->
    select = $(event.target)
    locationId = select.val()
    if locationId
      option = select.find("option[value='#{locationId}']")
      locationName = option.text()
      option.attr 'disabled', true
      $('ul#locations_list').append "<li>
        <a href='#' data-location-id='#{locationId}'>×</a>
        #{locationName}
      </li>"
      $('#locations_hidden_fields').append "<input type='hidden'
        name='retailer[location_ids][]'
        value='#{locationId}'
        data-location-id='#{locationId}'
      >"
      select.val ''

handleInputEvents = (locationsInput) ->
  locationsInput.on 'change', 'select', (event) ->
    changeHandlers[event.target.id] event

  locationsInput.on 'click', 'a[data-location-id]', (event) ->
    event.preventDefault()
    $('input[data-location-id="' + @dataset.locationId + '"]').remove()
    $("select#locations_select option[value='#{@dataset.locationId}']").removeAttr('disabled')
    $(@).parent('li').remove()

$ ->
  locationsInput = $ '#locations_admin_select'
  handleInputEvents(locationsInput) if locationsInput[0]
