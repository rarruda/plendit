window.controllers = window.controllers || {};
window.services = window.services || {};

window.services.responsive = {
    name: "responsive",
    callable: function() {

        function isGriddy() {
            return window.innerWidth < 640;
        }

        return {
            isGriddy: isGriddy
        }
    }
}



window.controllers.tagCreator = {
    callable: function(ele) {
        var inEle = ele;
        var outEle = document.querySelector("[data-payout]");

        inEle.addEventListener('change', syncPayout);
        inEle.addEventListener('keyup', syncPayout);
        syncPayout();

        function syncPayout() {
            var price = parseFloat(inEle.value);
            console.log(price)
            if (isNaN(price)) {
                outEle.value = "";
            }
            else {
                if (price == 0) {
                    outEle.value = 0;
                }
                else {
                    outEle.value = price * 0.90;
                }
            }
        }
    }
};

window.controllers.resultContainerSizeAdjuster = {
    dependencies: ["$element", "eventbus"],
    callable: function(ele, eventBus) {
        window.addEventListener('resize', adjustHeight);
        eventBus.on('filter-toggle', adjustHeight);
        adjustHeight();

        function adjustHeight() {
            var height = window.innerHeight - ele.offsetTop;
            ele.style.height = height + "px";
        }
    }
}

window.controllers.togglableFilters = {
    dependencies: ["$element", "eventbus"] ,
    callable: function(ele, eventBus) {
        var toggleEle = ele.querySelector("[data-filter-toggler]");
        var filterEle = ele.querySelector("[data-filter-container]");
        toggleEle.addEventListener('click', toggle);

        function toggle() {
            filterEle.classList.toggle("u-hidden");
            eventBus.emit('filter-toggle');
        }
    }
}