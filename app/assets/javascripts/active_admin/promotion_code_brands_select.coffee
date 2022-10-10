selectAll = (selectBox) ->
  selectBox2 = document.getElementById('promotion_code_brand_ids')

  i = 0
  while i < selectBox2.options.length
    selectBox2.options[i].selected = 'selected'
    i++

window["selectAll"] = selectAll
