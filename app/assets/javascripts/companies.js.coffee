jQuery ->
  Morris.Line(
    element: 'payments_chart'
    data: $('#payments_chart').data('payments')
    lineColors: [ '#ffffff' ]
    xkey: 'created_at'
    ykeys: ['payments', 'net_revenue', 'refunded_amount']
    labels: ['Payments', 'Net Revenue', "Refunded Amount"]
    pointSize: 3
    hideHover: 'auto'
    gridTextColor: '#ffffff'
    gridLineColor: 'rgba(255, 255, 255, 0.3)'
    lineColors: ['rgba(255, 255, 255, 1)', 'rgba(46, 204, 113, 1)', 'rgba(231, 76, 60, 1)']
    resize: true)
