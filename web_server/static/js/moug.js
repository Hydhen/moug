window.onload = function onLoad() {
    var circle = new ProgressBar.Circle('#timer', {
        color: '#FFB600',
        strokeWidth: 20,
        trailWidth: 20,
        duration: 4000,
    });

    circle.animate(1, {}, function() {
        // TODO WHEN GAME IS OVER
    });
};
