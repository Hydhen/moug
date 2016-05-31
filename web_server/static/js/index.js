// GLOBAL VARS
var active = false;
var games = 2;
var gamesIndex = 0;
var gamesList = {
    '0': {
        'name': 'tipioux',
        'description': 'La chasse aux Tipioux !',
        'img': '/static/img/games/tipioux.png',
    },
    '1': {
        'name': 'tipioux',
        'description': 'La chasse aux Tipioux (1) !',
        'img': '/static/img/games/tipioux.png',
    },
};


// CREATE CAROUSEL DIV
$.each(gamesList, function(key) {
    if (active == false) {
        $('#carousel-list').append('<div class="item active">'
            + '<img src="' + gamesList[key]['img']
            + '" class="games-img center-block" >'
            + '</div>'
        );
        $('#description-game').append(gamesList[key]['description']);
        active = true;
    }
    else {
        $('#carousel-list').append('<div class="item">'
            + '<img src="' + gamesList[key]['img']
            + '" class="games-img center-block" >'
            + '</div>'
        );
    }
});

// UPDATE CAROUSEL DESCRIPTION AND ID-GAME IN FORM
function updateCarousel() {
    $('#description-game').html('');
    $('#description-game').append(gamesList[gamesIndex]['description']);
    $('#id-game').attr("value", gamesIndex);
}


// CAROUSEL CONTROLS
$('#left').click(function() {
    if (gamesIndex == 0) {
        gamesIndex = games - 1;
    }
    else {
        gamesIndex = gamesIndex - 1;
    }
    updateCarousel();
});

$('#right').click(function() {
    if (gamesIndex == (games - 1)) {
        gamesIndex = 0;
    }
    else {
        gamesIndex = gamesIndex + 1;
    }
    updateCarousel();
});


// CAROUSEL WILL NOT AUTOPLAY
$('.carousel').carousel({
  interval: 0
});
