jQuery ->
  graphLine = Morris.Line(
    element: 'graph-line'
    data: [
      {
        period: '2014-01-01'
        iphone: 2666
        ipad: null
        itouch: 2647
      }
      {
        period: '2014-01-02'
        iphone: 9778
        ipad: 2294
        itouch: 2441
      }
      {
        period: '2014-01-03'
        iphone: 4912
        ipad: 1969
        itouch: 2501
      }
      {
        period: '2014-01-04'
        iphone: 3767
        ipad: 3597
        itouch: 5689
      }
      {
        period: '2014-01-05'
        iphone: 6810
        ipad: 1914
        itouch: 2293
      }
      {
        period: '2014-01-06'
        iphone: 5670
        ipad: 4293
        itouch: 1881
      }
      {
        period: '2014-01-07'
        iphone: 4820
        ipad: 3795
        itouch: 1588
      }
      {
        period: '2014-01-08'
        iphone: 15073
        ipad: 5967
        itouch: 5175
      }
      {
        period: '2014-01-09'
        iphone: 10687
        ipad: 4460
        itouch: 2028
      }
      {
        period: '2014-01-10'
        iphone: 8432
        ipad: 5713
        itouch: 1791
      }
    ]
    lineColors: [ '#ffffff' ]
    xkey: 'period'
    ykeys: [ 'iphone' ]
    labels: [ 'iPhone' ]
    pointSize: 3
    hideHover: 'auto'
    gridTextColor: '#ffffff'
    gridLineColor: 'rgba(255, 255, 255, 0.3)'
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
