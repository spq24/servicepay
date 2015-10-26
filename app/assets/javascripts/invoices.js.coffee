jQuery ->
    
  $(document).ready ->
    prices = []
    $('.inventory > tbody > tr').each ->
      activeRow = $(this).index()
      $('td:nth-child(1) select').addClass 'sel' + activeRow
      $('.sel' + activeRow).select2()
      price = accounting.unformat($(this).find('td:last input').val())
      prices.push price
    sum = prices.reduce(((pv, cv) ->
      pv + cv
      ), 0)
    $('.shown_total').text accounting.formatMoney(sum)
    totalDue = $('.shown_total').text()
    amountPaid = $('.amount_paid').text()
    balanceDue = accounting.unformat(totalDue) - accounting.unformat(amountPaid)
    $('.balance_due').text accounting.formatMoney(balanceDue)
    $('.total').val sum * 100
    
  $('form').on 'click', '.remove_fields', (event) ->
    $(this).prev('input[type=hidden]').val '1'
    $(this).closest('tr').hide()
    event.preventDefault()
    prices = []
    $('.inventory > tbody > tr').each ->
      if $(this).is(":visible")
        price = accounting.unformat($(this).find('td:last input').val())
        prices.push price
    sum = prices.reduce(((pv, cv) ->
      pv + cv
      ), 0)
    $('.shown_total').text accounting.formatMoney(sum)
    totalDue = $('.shown_total').text()
    amountPaid = $('.amount_paid').text()
    balanceDue = accounting.unformat(totalDue) - accounting.unformat(amountPaid)
    $('.balance_due').text accounting.formatMoney(balanceDue)
    $('.total').val sum * 100
    
  $('form').on 'click', '.add_fields', (event) ->
    time = (new Date).getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $('.inventory').append $(this).data('fields').replace(regexp, time)
    activeRow = $('.inventory tbody tr:last').index()
    $('.inventory tr:last td:nth-child(1) select').addClass 'sel' + activeRow
    $('.inventory tr:last td:nth-child(2) input:text').addClass 'description_' + activeRow    
    $('.inventory tr:last td:nth-child(3) input:text').addClass 'unit_cost_' + activeRow
    $('.inventory tr:last td:nth-child(3) input:hidden').addClass 'unit_cost_hidden_' + activeRow
    $('.inventory tr:last td:nth-child(4) input').addClass 'quantity_' + activeRow
    $('.inventory tr:last td:nth-child(5) input').addClass 'total_' + activeRow
    $('.inventory tr:last td:nth-child(5) input:hidden').addClass 'total_hidden_' + activeRow
    $('.sel' + activeRow).select2()
    event.preventDefault()
    
  $('form').on 'change', '.inventory tr', (event) ->
    activeRow = $(this).index()
    $(this).find('td:nth-child(2) input:text').addClass 'description_' + activeRow    
    $(this).find('td:nth-child(3) input:text').addClass 'unit_cost_' + activeRow
    $(this).find('td:nth-child(3) input:hidden').addClass 'unit_cost_hidden_' + activeRow
    $(this).find('td:nth-child(4) input').addClass 'quantity_' + activeRow
    $(this).find('td:nth-child(5) input').addClass 'total_' + activeRow
    $(this).find('td:nth-child(5) input:hidden').addClass 'total_hidden_' + activeRow
    selected = $(this).find('select option:selected').text().replace(/\s/g, '').toLowerCase()
    selectedDescription = $('#' + selected + '_description').text()
    selectedUnitcost = $('#' + selected + '_unit_cost').text()
    selectedQuantity = $('#' + selected + '_quantity').text()
    if $('.description_' + activeRow).val().length == 0
      $('.description_' + activeRow).val selectedDescription
    if $('.unit_cost_' + activeRow).val() == '$0.00'
      $('.unit_cost_' + activeRow).val accounting.formatMoney(selectedUnitcost / 100)
    if $('.quantity_' + activeRow).val().length == 0
      $('.quantity_' + activeRow).val parseInt(selectedQuantity, 10)
    quantity = $('.quantity_' + activeRow).val()
    unit_cost = $('.unit_cost_' + activeRow).val()
    fixedUnitcost = accounting.unformat(unit_cost)
    $('.unit_cost_hidden_' + activeRow).val fixedUnitcost * 100
    total = fixedUnitcost * quantity
    fixedTotal = accounting.formatMoney(total)
    if isNaN(total)
      $('.total_' + activeRow).val 0
    else
      $('.total_' + activeRow).val fixedTotal
      $('.total_hidden_' + activeRow).val total * 100
      prices = []
      $('.inventory tbody tr').each ->
        if $(this).is(":visible")
          price = accounting.unformat($(this).find('td:last input').val())
          prices.push price
      sum = prices.reduce(((pv, cv) ->
        pv + cv
      ), 0)
      $('.shown_total').text accounting.formatMoney(sum)
      totalDue = $('.shown_total').text()
      amountPaid = $('.amount_paid').text()
      balanceDue = accounting.unformat(totalDue) - accounting.unformat(amountPaid)
      $('.balance_due').text accounting.formatMoney(balanceDue)
      $('.total').val sum * 100
    return
  
  $('#recurring-fields').hide()
  
  $('.recurring-check').click ->
    $('#recurring-fields').fadeToggle()
