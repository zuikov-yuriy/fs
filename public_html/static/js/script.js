$(document).ready(function() {

    $(".files").hide();
    $('.open_files').click('click',function() {
        if ($(this).next().css('display') == 'none') {
            $(this).next().slideDown(200, function () {});
        }else {
            $(this).next().slideUp(200, function () {
             });
        }
    });

/*   $('img.img-rounded').click('click',function() {
        $(this).parents(".preview_block").css( "width", "450px" );
        $(this).parents(".preview_block").css( "position", "absolute" );
    });*/




});