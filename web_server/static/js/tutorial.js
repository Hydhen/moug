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
        xhttp.open("GET", "/start", true);
        xhttp.send();
        window.location.href = "/moug";
    }
    $('video').attr('src', '/static/mp4/' + videoList[videoIndex] + '.mp4');
    videoIndex = videoIndex + 1;
    $('video').load();
}
