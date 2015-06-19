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

window.controllers.postalPlaceFetcher = {
    callable: function(ele) {
        var lastSeen = "";
        var source = ele.querySelector("[data-postal-code]");
        var target = ele.querySelector("[data-postal-place]");
        var baseUrl = ele.getAttribute("data-postal-place-url");
        init();

        function init() {
            source.addEventListener('change', fetchPostalPlace);
            source.addEventListener('keyup', fetchPostalPlace);
            source.addEventListener('blur', fetchPostalPlace);
        }

        function fetchPostalPlace(evt) {
            if (lastSeen != evt.target.value) {
                lastSeen = evt.target.value;
                var url = baseUrl + "?postal_code=" + evt.target.value;
                xhr.get(url).then(updatePostalPlace);
            }
        }

        function updatePostalPlace(xhr) {
            target.value = xhr.responseText;
        }
    }
};

window.controllers.resetUnseenNotificationCount = function(ele) {
    var hasBeenReset = false;
    ele.addEventListener('click', function() {
        if (!hasBeenReset) {
            hasBeenReset = true;
            var url = ele.getAttribute("data-clear-notifications-url");
            xhr.post(url);
            var countEle = ele.querySelector("[data-notification-count]");
            if (countEle) {
                countEle.classList.add('u-hidden');
            }
        }
    });
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

window.services.searchService = {
    name: "searchService",
    dependencies: ["eventbus"],
    callable: function(eventBus) {

        function search(form) {
            var url = '/search.json?=' + buildQuery(form);
            history.replaceState(null, null, url.replace(".json", ""));
            xhr.get(url).then(onSearchFinished);
        }

        function onSearchFinished(response) {
            var result = JSON.parse(response.responseText);
            eventBus.emit('new-search-result', result);
        }

        function buildQuery(form) {
            var items = [];
            for (var key in form) {
                items.push({key: key, value: form[key]});
            }

            items = items.map(function(e) {
                return e.key + "=" + e.value;
            });

            return items.join("&");
        }

        return {
            search: search
        }
    }
}

window.controllers.searchFilterSelection = {
    dependencies: ["$element", "eventbus", "searchService"],
    callable: function(ele, eventBus, searchService) {

        init();

        function init() {
            var inputs = ele.querySelectorAll("input");
            for (var n = 0, e; e = inputs[n++];) {
                e.addEventListener('change', onInputChange);
            }
        }

        function onInputChange(evt) {
            evt.preventDefault();
            searchService.search(getFormValues());
        }

        function getFormValues() {
            var form = {};
            var inputs = ele.querySelectorAll("input");
            for (var n = 0, e; e = inputs[n++];) {
                if (e.name && e.value) {
                    form[e.name] = e.value;
                }
            }
            return form;
        }
    }
}

window.controllers.calenderPager = {
    dependencies: ["$element"],
    callable: function(ele) {
        ele.addEventListener('click', onClick);

        function onClick(evt) {
            var e = evt.target;
            if (e && e.nodeName.toLowerCase() == "a") {
                evt.preventDefault();
                var url = e.href;
                xhr.get(url).then(onNewCalendarFetched)
            }
        }

        function onNewCalendarFetched(xhr) {
            var e = document.createElement("div");
            e.innerHTML = xhr.responseText;
            var newCal = e.querySelector("[data-calendar]");
            var oldCal = ele.querySelector("[data-calendar]");
            oldCal.parentNode.replaceChild(newCal, oldCal);
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

window.controllers.resultList = {
    dependencies: ["$element", "eventbus"] ,
    callable: function(ele, eventBus) {
        eventBus.on('new-search-result', onSearchResult);
        function onSearchResult(result) {
            if (result && result.markup != null) {
                ele.innerHTML = result.markup;
            }
        }
    }
}