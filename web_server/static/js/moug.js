window.onload = function onLoad() {
    var circle = new ProgressBar.Circle('#timer', {
        color: '#2F2B83',
        strokeWidth: 13,
        trailWidth: 13,
        duration: 4000,
    });

    circle.animate(1, {}, function() {
        // TODO WHEN GAME IS OVER
    });
};
