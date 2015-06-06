window.controllers = window.controllers || {};

window.controllers.menuAnchor = {
    dependencies: ["$element", "eventbus"] ,
    callable: function(ele, eventBus) {

        var targetSelector = ele.getAttribute("data-anchor-for");
        var targetBox = document.querySelector(targetSelector);
        var anchorId = (new Date()).getTime();
        var visible = false;

        ele.addEventListener("click", onAnchorClick);
        eventBus.on("anchor-toggle", onAnchorToggleEvent);

        function onAnchorClick(evt) {
            evt.preventDefault();
            eventBus.emit("anchor-toggle", anchorId);
            toggle();
        }

        function onAnchorToggleEvent(id) {
            if (id != anchorId) { hide(); }
        }

        function positionElement(anchor, subject) {
            var left = "" + (anchor.offsetLeft - 330) + "px";
            var top = "" + (anchor.offsetTop + 32) + "px";
            subject.style.top = top;
            subject.style.left = left;
        }

        function toggle() {
            if (visible) { hide(); } 
            else { show(); } 
        }

        function hide() {
            targetBox.classList.add("u-hidden");
            visible = false;
        }

        function show() {
            positionElement(ele, targetBox);
            targetBox.classList.remove("u-hidden");
            visible = true;
        }
    }
}
