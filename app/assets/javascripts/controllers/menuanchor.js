window.controllers = window.controllers || {};

window.controllers.menuAnchor = {
    dependencies: ["$element", "eventbus", "responsive"] ,
    callable: function(ele, eventBus, responsive) {
        var targetSelector = ele.getAttribute("data-anchor-for");
        var targetBox = document.querySelector(targetSelector);
        window.addEventListener("resize", positionElement);

        attachorize();

        function attachorize() {
            window.setTimeout(function() {
                ele.addEventListener("click", show);
            }, 1);
        }

        function positionElement() {
            if (responsive.isGriddy()) {
                var left = "" + (ele.offsetLeft - 350) + "px";
                var top = "" + (ele.offsetTop + 32) + "px";
                targetBox.style.top = top;
                targetBox.style.left = left;
            }
            else {
                targetBox.style.top = 0;
                targetBox.style.left = 0;
            }
        }

        function hide(evt) {
            var hideIt = false;
            if (!responsive.isGriddy()) {
                var container = evt.target.closest("[data-anchor-for]");
                hideIt = !!container;
            }
            else {
                var container = evt.target.closest("[data-floating-notifications]");
                hideIt = !container;
            }

            if (hideIt) {
                targetBox.classList.add("u-hidden");
                window.removeEventListener("click", hide, 'true');
                attachorize();                
            }
        }

        function show() {
            positionElement(ele, targetBox);
            targetBox.classList.remove("u-hidden");
            ele.removeEventListener("click", show);
            window.addEventListener("click", hide, 'true');
        }
    }
}
