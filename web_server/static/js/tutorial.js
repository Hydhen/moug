var videoIndex = 0;
var videoList = [
//    '02-introduction',
//    '03-push-the-button',
//    '04-instruction1',
//    '05-instruction2',
    '06-count',
];

document.getElementById('video').addEventListener('ended', nextStep, false);

function nextStep(e) {
    if (videoIndex > (videoList.length - 1)) {
        var xmlHttp = new XMLHttpRequest();
        xmlHttp.onreadystatechange = function() {
            if (xmlHttp.readyState == 4 && xmlHttp.status == 200)
                console.log(xmlHttp.responseText);
        }
        xmlHttp.open("GET", "/start", true); // true for asynchronous
        xmlHttp.send(null);
        window.location.href = "/moug";
    }
    $('video').attr('src', '/static/mp4/' + videoList[videoIndex] + '.mp4');
    videoIndex = videoIndex + 1;
    $('video').load();
}
