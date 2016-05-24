$(".action-button").click(function() {
    var id = $(this).attr("id");
    console.log("Pressed : " + id);

    $.ajax({
    type: 'GET',
    url: '/' + id,
    dataType: 'json',
    error: function (data) {
            console.log("ERROR :");
            alert(data["content"])
        },
    success: function (data) {
            console.log("SUCCESS :");
            alert(data["content"])
        }
    });
});

$('.carousel').carousel({
  interval: 0
})
