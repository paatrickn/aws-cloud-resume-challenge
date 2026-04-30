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
        var dot = document.querySelector(".counter-dot");
        dot.classList.remove("blink");
        void dot.offsetWidth; // force reflow so re-adding the class restarts the animation
        dot.classList.add("blink");

        var plusOne = document.createElement("span");
        plusOne.className = "counter-plus-one";
        plusOne.textContent = "+1";
        var bar = document.querySelector(".counter-bar");
        var valEl = document.getElementById("visits_count");
        var rect = valEl.getBoundingClientRect();
        var barRect = bar.getBoundingClientRect();
        plusOne.style.left = (rect.right - barRect.left + 4) + "px";
        plusOne.style.top = "0px";
        bar.appendChild(plusOne);

        setTimeout(function () {
            dot.classList.remove("blink");
            plusOne.remove();
        }, 1000);
    }
};
xhttp.open("GET", "https://pi8qackvt7.execute-api.us-west-1.amazonaws.com/default/incrementViewcount", true);
xhttp.send();







// function api_view_count() {
//     const view = data.view[0]
//     const viewDiv = document.getElementById("views");

// }
