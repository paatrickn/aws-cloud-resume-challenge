var xhttp = new XMLHttpRequest();
xhttp.onreadystatechange = function () {
    if (this.readyState == 4 && this.status == 200) {
        var newCount = parseInt(xhttp.responseText, 10);
        var valEl = document.getElementById("visits_count");

        if (isNaN(newCount)) {
            valEl.textContent = xhttp.responseText;
            return;
        }

        var oldCount = newCount - 1;

        // Show old count as individual digit spans
        renderDigits(valEl, String(oldCount));

        // Blink dot
        var dot = document.querySelector(".counter-dot");
        dot.classList.remove("blink");
        void dot.offsetWidth;
        dot.classList.add("blink");

        // Float +1 to the right of the number
        var plusOne = document.createElement("span");
        plusOne.className = "counter-plus-one";
        plusOne.textContent = "+1";
        var bar = document.querySelector(".counter-bar");
        var rect = valEl.getBoundingClientRect();
        var barRect = bar.getBoundingClientRect();
        plusOne.style.left = (rect.right - barRect.left + 4) + "px";
        plusOne.style.top = "0px";
        bar.appendChild(plusOne);

        // Roll changed digits up to the new value after +1 appears
        setTimeout(function () {
            rollDigits(valEl, String(oldCount), String(newCount));
        }, 350);

        setTimeout(function () {
            dot.classList.remove("blink");
            plusOne.remove();
        }, 1100);
    }
};
xhttp.open("GET", "https://pi8qackvt7.execute-api.us-west-1.amazonaws.com/default/incrementViewcount", true);
xhttp.send();

function renderDigits(el, str) {
    el.innerHTML = '';
    for (var i = 0; i < str.length; i++) {
        var wrap = document.createElement('span');
        wrap.className = 'counter-digit-wrap';
        var digit = document.createElement('span');
        digit.className = 'counter-digit';
        digit.textContent = str[i];
        wrap.appendChild(digit);
        el.appendChild(wrap);
    }
}

function rollDigits(el, oldStr, newStr) {
    // Pad old string to match new length (e.g. 99 -> 100)
    while (oldStr.length < newStr.length) oldStr = '0' + oldStr;

    el.innerHTML = '';
    for (var i = 0; i < newStr.length; i++) {
        var wrap = document.createElement('span');
        wrap.className = 'counter-digit-wrap';

        if (oldStr[i] !== newStr[i]) {
            // Stack: old digit on top, new digit below — animate up
            var stack = document.createElement('span');
            stack.className = 'counter-digit-stack';
            var dOld = document.createElement('span');
            dOld.className = 'counter-digit';
            dOld.textContent = oldStr[i];
            var dNew = document.createElement('span');
            dNew.className = 'counter-digit';
            dNew.textContent = newStr[i];
            stack.appendChild(dOld);
            stack.appendChild(dNew);
            wrap.appendChild(stack);
            (function (s) {
                requestAnimationFrame(function () {
                    requestAnimationFrame(function () {
                        s.style.transform = 'translateY(-1.15em)';
                    });
                });
            })(stack);
        } else {
            var digit = document.createElement('span');
            digit.className = 'counter-digit';
            digit.textContent = newStr[i];
            wrap.appendChild(digit);
        }

        el.appendChild(wrap);
    }
}
