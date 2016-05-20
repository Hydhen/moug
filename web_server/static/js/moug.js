var duration = Number(localStorage.duration) + 3

var circle = new ProgressBar.Circle('#timer', {
    color: '#2F2B83',
    strokeWidth: 13,
    trailWidth: 13,
    duration: duration * 1000,// * 60,
});

circle.animate(1, {}, function() {
    $('video').attr('src', '/static/mp4/08-last5sec.mp4');
    $('video').load();
    console.log("video loaded");

    function nextStep() {
        console.log("nextStep called");
        var xmlHttp = new XMLHttpRequest();
        xmlHttp.onreadystatechange = function() {
            if (xmlHttp.readyState == 4 && xmlHttp.status == 200)
                console.log(xmlHttp.responseText);
        }
        xmlHttp.open("GET", "/stop", true);
        xmlHttp.send(null);
        window.location.href = "/end";
    }

    window.setTimeout(nextStep, 5000);
});
