var red = Number(localStorage.redScore);
var blue = Number(localStorage.blueScore);

if (red > blue) {
    videoName = "09-winner-jaune";
    var tmp = (blue * 100) / red;
    blue = tmp + "%";
    red = "100%";
} else if (red < blue) {
    videoName = "09-winner-bleu";
    var tmp = (red * 100) / blue;
    red = tmp + "%";
    blue = "100%";
} else {
    videoName = "09-winner-nul";
    red = "100%"
    blue = "100%"
}

$('video').attr('src', '/static/mp4/' + videoName + '.mp4');
$('video').load();

$('#blueScore').html(localStorage.blueScore);
$('#redScore').html(localStorage.redScore);

var blueBar = $('.blue').find('.inner');
$(blueBar).animate({
    height: blue
}, 1500);

var redBar = $('.red').find('.inner');
$(redBar).animate({
    height: red
}, 1500);
