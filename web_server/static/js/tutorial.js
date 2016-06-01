var videoIndex = 0;
var videoList = [
    'push-the-button',
    'instruction-1',
    'instruction-2',
    'team',
];

document.getElementById('video').addEventListener('ended', nextStep, false);

function nextStep(e) {
    if (videoIndex > (videoList.length - 1)) {
        window.location.href = "/moug";
    }
    $('video').attr('src', '/static/mp4/' + videoList[videoIndex] + '.mp4');
    videoIndex = videoIndex + 1;
    $('video').load();
}
