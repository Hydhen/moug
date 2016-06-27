console.log('SCORE_RED : ' + localStorage.redScore);
console.log('SCORE_BLUE: ' + localStorage.blueScore);


// document.getElementById('video').addEventListener('ended', nextStep, false);
//
// console.log(localStorage.duration);
//
// function nextStep(e) {
//     if (videoIndex > (videoList.length - 1)) {
//         var xmlHttp = new XMLHttpRequest();
//         xmlHttp.onreadystatechange = function() {
//             if (xmlHttp.readyState == 4 && xmlHttp.status == 200)
//                 console.log(xmlHttp.responseText);
//         }
//         xmlHttp.open("GET", "/start", true); // true for asynchronous
//         xmlHttp.send(null);
//         window.location.href = "/moug";
//     }
//     $('video').attr('src', '/static/mp4/' + videoList[videoIndex] + '.mp4');
//     videoIndex = videoIndex + 1;
//     $('video').load();
// }
