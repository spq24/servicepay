jQuery ->
  Morris.Line(
    element: 'payments_chart'
    data: $('#payments_chart').data('payments')
    lineColors: [ '#ffffff' ]
    xkey: 'created_at'
    ykeys: ['payments', 'amounts']
    labels: ['Payments', 'Amount']
    pointSize: 3
    hideHover: 'auto'
    gridTextColor: '#ffffff'
    gridLineColor: 'rgba(255, 255, 255, 0.3)'
    lineColors: ['rgba(255, 255, 255, 1)', 'rgba(46, 204, 113, 1)']
    resize: true)

$ ($) ->
  #tooltip init
  $('#exampleTooltip').tooltip()
  #nice select boxes
  $('#sel2').select2()
  #masked inputs
  $('#maskedDate').mask '99/99/9999'
  $('#maskedPhone').mask '(999) 999-9999'
  $('#maskedPhoneExt').mask '(999) 999-9999? x99999'
  $('#maskedTax').mask '99-9999999'
  $('#maskedSsn').mask '999-99-9999'
  $.mask.definitions['~'] = '[+-]'
  $('#maskedEye').mask '~9.99 ~9.99 999'
  return
