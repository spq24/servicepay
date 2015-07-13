$(function() {
    $('#months').hide(); 
    $('#duration_select').change(function(){
        if($('#duration_select').val() == 'repeating') {
            $('#months').show(); 
        } else {
            $('#months').hide(); 
        } 
    });
});

$(function($) {
	//datepicker
	$('#datepickerDate').datepicker({
	  format: 'mm/dd/yyyy'
	});
});