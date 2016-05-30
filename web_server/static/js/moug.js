window.onload = function onLoad() {
    var circle = new ProgressBar.Circle('#timer', {
        color: '#FFB600',
        strokeWidth: 11,
        trailWidth: 11,
        duration: 30000,
    });

    circle.animate(1);
    $('#timer').width(114);
};
