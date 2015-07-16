// Javascript Document

/* =================================
   LOADER                     
=================================== */
// makes sure the whole site is loaded
$(window).load(function() {

    "use strict";

    // will first fade out the loading animation
    $(".signal").fadeOut();
        // will fade out the whole DIV that covers the website.
    $(".preloader").fadeOut("slow");

});



/* =================================
   SCROLL NAVBAR
=================================== */
$(window).scroll(function(){
    "use strict";
    var b = $(window).scrollTop();
    if( b > 60 ){
        $(".navbar").addClass("is-scrolling");
    } else {
        $(".navbar").removeClass("is-scrolling");
    }
});


/* =================================
   DATA SPY FOR ACTIVE SECTION                 
=================================== */
(function($) {
    
    "use strict";
    
    $('body').attr('data-spy', 'scroll').attr('data-target', '.navbar-fixed-top').attr('data-offset', '11');

})(jQuery);


/* =================================
   HIDE MOBILE MENU AFTER CLICKING 
=================================== */
(function($) {
    
    "use strict";
    
    $('.nav.navbar-nav li a').click(function () {
        var $togglebtn = $(".navbar-toggle");
        if (!($togglebtn.hasClass("collapsed")) && ($togglebtn.is(":visible"))){
            $(".navbar-toggle").trigger("click");
        }
    });

})(jQuery);


/* ==================================================== */
/* ==================================================== */
/* =======================================================
   DOCUMENT READY
======================================================= */
/* ==================================================== */
/* ==================================================== */

$(document).on('ready page:load', function () {


"use strict";


/* =====================================
    PARALLAX STELLAR WITH MOBILE FIXES                    
======================================== */
if (Modernizr.touch && ($('.header').attr('data-stellar-background-ratio') !== undefined)) {
    $('.header').css('background-attachment', 'scroll');
    $('.header').removeAttr('data-stellar-background-ratio');
} else {
    $(window).stellar({
        horizontalScrolling: false
    });
}

/* =================================
    WOW ANIMATIONS                   
=================================== */
new WOW().init();

/* ==========================================
    EASY TABS
============================================= */
$('.tabs.testimonials').easytabs({
    animationSpeed: 300,
    updateHash: false,
    cycle: 10000
});

$('.tabs.features').easytabs({
    animationSpeed: 300,
    updateHash: false
});


/* ==========================================
   OWL CAROUSEL 
============================================= */
/* App Screenshot Carousel in Mobile-Download Section */
$("#owl-carousel-shots-phone").owlCarousel({
    singleItem:true,navigation: true,
    navigationText: [
        "<i class='icon arrow_carrot-left'></i>",
        "<i class='icon arrow_carrot-right'></i>"
                    ],
    addClassActive : true,
    itemsDesktop : [1200, 1],
    itemsDesktopSmall : [960, 1],
    itemsTablet : [769, 1],
    itemsMobile : [700, 1],
    responsiveBaseWidth : ".shot-container",
    items : 1,
    slideSpeed : 1000,
    mouseDrag : true,
    responsiveRefreshRate : 200,
    autoPlay: 5000
});

/* ==========================================
    VENOBOX - LIGHTBOX FOR GALLERY AND VIDEOS
============================================= */
$('.venobox').venobox();


/* =================================
   SCROLL TO                  
=================================== */
var onMobile;

onMobile = false;
if (/Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.userAgent)) { onMobile = true; }

if (onMobile === true) {
    jQuery('a.scrollto').click(function (event) {
    jQuery('html, body').scrollTo(this.hash, this.hash, {gap: {y: -10}, animation:  {easing: 'easeInOutCubic', duration: 0}});
    event.preventDefault();
});
} else {
    jQuery('a.scrollto').click(function (event) {
    jQuery('html, body').scrollTo(this.hash, this.hash, {gap: {y: -10}, animation:  {easing: 'easeInOutCubic', duration: 1500}});
        event.preventDefault();
});
}


/* ========================================================================================
   FAST-REGISTRATION VALIDATION. WITHOUT CONFIRM PSW. FIELD VALUES WILL BE SENT TO SIGNUP.PHP
=========================================================================================== */
$("#fast-reg").submit(function(e) {
    e.preventDefault();
    var data = {
        name: $("#fast-name").val(),
        email: $("#fast-email").val(),
        password: $("#fast-password").val()
    };

    if ( isValidEmail(data['email']) && (data['password'].length > 1) && (data['name'].length > 1) ) {
        $.ajax({
            type: "POST",
            url: "assets/php/subscribe.php",
            data: data,
            success: function() {
                $('.fast-success').fadeIn(1000);
                $('.fast-failed').fadeOut(500);
            }
        });
    } else {
        $('.fast-failed').fadeIn(1000);
        $('.fast-success').fadeOut(500);
    }

    return false;
});

/* =======================================================================
   DOUGHNUT CHART
========================================================================== */
var isdonut = 0;
        
$('.start-charts').waypoint(function(direction){
    if (isdonut == 1){}
        else {
            var doughnutData = [
                {
                    value: 88,
                    color:"#B91004",
                    highlight: "#EA402F",
                    label: "% of People Read Online Reviews"
                },
                {
                    value: 12,
                    color: "#323A45",
                    highlight: "#4C5B70",
                    label: "% Of People Don't"
                }

            ];

            var doughnut2Data = [
                {
                    value: 86,
                    color:"#C0392B",
                    highlight: "#EA402F",
                    label: "% Of Make Decisions From Online Reviews"
                },
                {
                    value: 14,
                    color: "#323A45",
                    highlight: "#4C5B70",
                    label: "% Of People Don't"
                }
            ];

            
            
            var ctx = document.getElementById("chart-area").getContext("2d");
            window.myDoughnut = new Chart(ctx).Doughnut(doughnutData, {responsive : false});

            var ctx = document.getElementById("chart2-area").getContext("2d");
            window.myDoughnut = new Chart(ctx).Doughnut(doughnut2Data, {responsive : false});

            isdonut = 1;
        }
});

/* =======================================================================
   LINE CHART
========================================================================== */
var isline = 0;
        
$('.start-line').waypoint(function(direction){
    if (isline == 1){}
        else {

            var lineChartData = {
                labels : ["January","February","March","April","May","June","July"],
                datasets : [
                    {
                        label: "Leads",
                        fillColor : "rgba(192,57,43,0.2)",
                        strokeColor : "rgba(192,57,43,1)",
                        pointColor : "rgba(192,57,43,1)",
                        pointStrokeColor : "#fff",
                        pointHighlightFill : "#fff",
                        pointHighlightStroke : "rgba(192,57,43,1)",
                        data : [680,256,728,831,813,1510,1604]
                    },
                    {
                        label: "Cost Per Lead",
                        fillColor : "rgba(50,58,69,0.2)",
                        strokeColor : "rgba(50,58,69,1)",
                        pointColor : "rgba(50,58,69,1)",
                        pointStrokeColor : "#fff",
                        pointHighlightFill : "#fff",
                        pointHighlightStroke : "rgba(50,58,69,1)",
                        data : [25.29,57.81,37.36,30.32,27.55,20.66,21.70]
                    }
                ]

            };

            var ctx = document.getElementById("line-canvas").getContext("2d");
            window.myLine = new Chart(ctx).Line(lineChartData, {responsive: true});

            isline = 1;
        }
});

/* =======================================================================
   SIGNUP-DIVIDER ANIMATED POLYGON BACKGROUND
========================================================================== */
    var container = document.getElementById('canvas-bg');
    var renderer = new FSS.CanvasRenderer();
    var scene = new FSS.Scene();
    var light = new FSS.Light('323A45', '323A45');
    var geometry = new FSS.Plane(2000, 1000, 15, 8);
    var material = new FSS.Material('FFFFFF', 'FFFFFF');
    var mesh = new FSS.Mesh(geometry, material);
    var now, start = Date.now();

    function initialise() {
      scene.add(mesh);
      scene.add(light);
      container.appendChild(renderer.element);
      window.addEventListener('resize', resize);
    }

    function resize() {
      renderer.setSize(container.offsetWidth, container.offsetHeight);
    }

    function animate() {
      now = Date.now() - start;
      light.setPosition(300*Math.sin(now*0.001), 200*Math.cos(now*0.0005), 60);
      renderer.render(scene);
      requestAnimationFrame(animate);
    }

    initialise();
    resize();
    animate();


/* ===========================================================
   BOOTSTRAP FIX FOR IE10 in Windows 8 and Windows Phone 8  
============================================================== */
if (navigator.userAgent.match(/IEMobile\/10\.0/)) {
    var msViewportStyle = document.createElement('style');
    msViewportStyle.appendChild(
        document.createTextNode(
            '@-ms-viewport{width:auto!important}'
            )
        );
    document.querySelector('head').appendChild(msViewportStyle);
}


});