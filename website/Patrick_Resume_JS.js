// function changeColor() {
//     document.getElementById("demo").innerHTML = "NOT_A_NUMBER";
// }


// fetch("https://pi8qackvt7.execute-api.us-west-1.amazonaws.com/default/incrementViewcount")
//     .then(views => {
//         console.log(views);
//         api_view_count(views)
//     })


var xhttp = new XMLHttpRequest();
xhttp.onreadystatechange = function () {
    if (this.readyState == 4 && this.status == 200) {
        document.getElementById("visits_count").innerHTML = xhttp.responseText;
    }
};
xhttp.open("GET", "https://pi8qackvt7.execute-api.us-west-1.amazonaws.com/default/incrementViewcount", true);
// xhttp.setRequestHeader('Access-Control-Allow-Origin', 'https://paatrick.com');
xhttp.send();







// function api_view_count() {
//     const view = data.view[0]
//     const viewDiv = document.getElementById("views");

// }
