document.getElementById('video').addEventListener('ended', nextStep, false);
function nextStep(e) {
    alert("Moving to the next step");
}
