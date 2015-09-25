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
};

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
                var pnum = evt.target.value.replace(/\D/g)
                if (pnum.length == 4) {
                    var url = baseUrl + "?postal_code=" + evt.target.value;
                    xhr.get(url).then(updatePostalPlace);
                }
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
};

window.services.searchService = {
    name: "searchService",
    dependencies: ["eventbus"],
    callable: function(eventBus) {
        var params = {};
        var bounds = {};
        var zl = 14;
        var mostRecentResult;
        var page = 1;

        var queryBlackList = {
            utf8: true,
            authenticity_token: true,
            page: true
        };

        init();

        function init() {
            var jsonContainer = document.querySelector("[data-location-info]");
            mostRecentResult = JSON.parse(jsonContainer.textContent);

            var parts = window
                .location.search.split(/[\?&]/)
                .filter(function(e) { return e; })
                .map(function(e) { return e.split('='); });

            parts
                .filter(boundsFilter)
                .forEach(function(e) {
                    bounds[e[0]] = e[1];
                });
            parts
                .filter(invertFilter(boundsFilter))
                .forEach(function(e) {
                    params[e[0]] = e[1];
                });
        }

        function boundsFilter(e) {
            return ['ne_lat', 'ne_lon', 'sw_lat', 'sw_lon'].indexOf(e[0]) != -1;
        }

        function invertFilter(fun) {
            return function(e) { return !fun(e); }
        }

        function merge(a,b) {
            var ret = {};
            var key;
            for (key in a) { ret[key] = a[key] }
            for (key in b) { ret[key] = b[key] }
            return ret;
        }

        function search() {
            form = merge(params, {});
            form = merge(form, bounds);
            form = merge(form, zl);

            var url = '/search.json?' + buildQuery(form);
            history.replaceState(null, null, url.replace(".json", ""));
            xhr.get(url).then(onSearchFinished);
            eventBus.emit('search-started');
        }

        function setBounds(b) {
            bounds = b;
        }

        function setZoom(zoom) {
            zl = zoom;
        }

        function setSearchParams(p) {
            params = p;
        }

        function setPage(p) {
            page = p;
        }

        function resultsAreDifferent(first, second) {
            return idKeyFromResult(first) != idKeyFromResult(second);
        }

        function idKeyFromResult(result) {
            if (result && result.ads) {
                var ids = Object.keys(result.ads);
                ids.sort();
                return ids.join(",");
            }
            else {
                return "";
            }
        }

        function onSearchFinished(response) {
            var result = JSON.parse(response.responseText);
            if (resultsAreDifferent(result, mostRecentResult)) {
                mostRecentResult = result;
                eventBus.emit('new-search-result', result);
            }
            else {
                eventBus.emit('old-search-result', mostRecentResult);
            }
        }

        function buildQuery(form) {
            var items = [];
            for (var key in form) {
                var val = form[key];
                if (val.constructor != Array) {
                    val = [val];
                }
                else {
                    key = key + "[]";
                }

                val.forEach(function(e) {
                    items.push({key: key, value: e});
                });
            }

            items = items.filter(function(e) {
                return !queryBlackList[e.key];
            });

            items = items.map(function(e) {
                return e.key + "=" + e.value;
            });

            items.push("page=" + page);
            return items.join("&");
        }

        return {
            search: search,
            setSearchParams: setSearchParams,
            setBounds: setBounds,
            setZoom: setZoom,
            setPage: setPage,
            getMostRecentSearchResult: function() { return mostRecentResult; }
        }
    }
};

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
            searchService.setSearchParams(getFormValues());
            searchService.search();
        }

        function getFormValues() {
            return formToObj(ele.querySelector("form"));
        }
    }
};

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
};

window.controllers.togglableFilters = {
    dependencies: ["$element", "eventbus"] ,
    callable: function(ele, eventBus) {
        var toggleEle = ele.querySelector("[data-filter-toggler]");
        var filterEle = ele.querySelector("[data-filter-container]");
        toggleEle.addEventListener('click', toggle);

        function toggle() {
            filterEle.classList.toggle("u-hidden");
            eventBus.emit('filter-toggle');
            eventBus.emit('layout-changed');
        }
    }
};

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
};

window.controllers.hitCount = {
    dependencies: ["$element", "eventbus"] ,
    callable: function(ele, eventBus) {
        eventBus.on('new-search-result', onSearchResult);
        eventBus.on('old-search-result', onSearchResult);
        eventBus.on('search-started', onSearchStarted);
        eventBus.on('map-will-change', onSearchStarted);

        function onSearchResult(result) {
            ele.textContent = "" + Math.min(result.paging.default_per_page, result.paging.total_count) + " treff av " + result.paging.total_count + ".";
        }

        function onSearchStarted() {
            ele.textContent = "Søker…";
        }
    }
}
;
window.controllers.autoSizeTextArea = {
    callable: function(ele) {
        ele.addEventListener('change', adjustSize);
        ele.addEventListener('keyup', adjustSize);
        adjustSize();

        function adjustSize() {
            if (ele.scrollHeight > ele.offsetHeight) {
                ele.style.minHeight = (ele.scrollHeight + 44) + "px";
            }
        }
    }
};

window.controllers.submitMainForm = function(ele) {
    ele.addEventListener("click", function() {
        document.querySelector("[data-main-form]").submit();
    });
};

window.controllers.imageDescriptionAutoSaver = {
    dependencies: ["$element", "utils", "xhr"],
    callable: function(ele, utils, xhr) {
        var ta = ele.querySelector("textarea");
        var submitFun = utils.debounce(function(evt) { 
            evt.preventDefault();
            ajaxSubmitForm(ele);

        }, 1000);
        ta.addEventListener('keyup', submitFun);
        ta.addEventListener('change', submitFun);

        function ajaxSubmitForm(form) {
            xhr
                .xhrFormData(form)
                .catch(function(err) {
                    console.log("ARRAR!", err);
                });
        }
    }
};

window.controllers.kalendaeBookingSelector = {
    dependencies: ["$element"],
    callable: function(ele) {
        var calCount = 3;
        if (window.innerWidth < 660) { calCount = 1; }
        else if (window.innerWidth < 972) { calCount = 2; }

        var from_date = ele.querySelector('[name="booking[starts_at_date]"]');
        var to_date = ele.querySelector('[name="booking[ends_at_date]"]');
        var rangeString = from_date.value + " - " + to_date.value;

        var k = new Kalendae({
            attachTo: ele.querySelector("[data-kalendae-container]"),
            months: calCount,
            mode: 'range',
            weekStart: 1,
            direction: "today-future",
            selected: rangeString
        });

        k.subscribe('change', function(date) {
            window.k = k;
            var dates = this.getSelectedAsText();

            if (dates.length == 2) {
                from_date.value = dates[0];
                to_date.value = dates[1];
            }
            else {
                from_date.value = dates[0];
                to_date.value = dates[0];
            }
        });
    }
};

window.controllers.readOnlyCalendar = function(ele) {
    var calCount = 3;
    if (window.innerWidth < 660) { calCount = 1; }
    else if (window.innerWidth < 972) { calCount = 2; }

    var k = new Kalendae({
        attachTo: ele,
        months: calCount,
        mode: 'range',
        readOnly: true,
        weekStart: 1,
        direction: "today-future",
        selected: ele.getAttribute('data-date-range')
    });
};

window.controllers.listingCalendar = function(ele) {
    var selected = "";

    function onViewChanged(yearOrWeek) {
        var now = moment();
        var then = this.viewStartDate.clone().add(1, "month");
        if (then.diff(now, 'years') > 0) { return false }
    }

    var bookedDatesEle = ele.querySelector('script[type="text/plain"]');
    if (bookedDatesEle) {
        selected = bookedDatesEle.textContent.trim();
    }

    var k = new Kalendae({
        attachTo: ele,
        months: 1,
        mode: 'multiple',
        readOnly: true,
        weekStart: 1,
        direction: "today-future",
        blackout: selected,
        useYearNav: false,
        subscribe: {
            "view-changed": onViewChanged
        }
    });
};


window.controllers.videoTrigger = {
    dependencies: ['$element', 'responsive'],
    callable: function(ele, responsive) {
        if (!responsive.isGriddy()) {
            ele.play();
        }
    }
};

window.controllers.addressSelectionDimmer = function(ele) {
    var select = ele.querySelector("select");
    var details = ele.querySelector("details");
    var summary = ele.querySelector("summary");
    var input = ele.querySelector("[name=create_new_location]");
    summary.addEventListener("click", onSummaryToggle);

    function onSummaryToggle() {
        var opened = !details.open; // old state when clicked
        select.disabled = opened;
        input.value = Number(opened).toString();
    }
};

window.controllers.autoFocus = function(ele) {
    ele.focus();
};


window.controllers.responsiveSearchResult = {
    dependencies: ["$element", "eventbus"],
    callable: function(ele, eventBus) {

        var map;
        var list;
        var listButton;
        var mapButton;

        init();

        function init() {
            list = document.querySelector("[data-result-list]");
            map = document.querySelector("[data-result-map]");
            mapButton = document.querySelector("[data-show-map-toggle]");
            listButton = document.querySelector("[data-show-list-toggle]");

            mapButton.addEventListener("click", showMap);
            listButton.addEventListener("click", showList);
        }

        function showMap() {
            map.style.display = "block";
            list.style.display = "none";
            mapButton.classList.add("search-result-view-chooser__segment-button--selected");
            listButton.classList.remove("search-result-view-chooser__segment-button--selected");
            eventBus.emit('layout-changed');
        }

        function showList() {
            map.style.display = "none";
            list.style.display = "block";
            mapButton.classList.remove("search-result-view-chooser__segment-button--selected");
            listButton.classList.add("search-result-view-chooser__segment-button--selected");
        }

    }
};


window.controllers.resultPaging = {
    dependencies: ["$element", "searchService"],
    callable: function(ele, searchService) {
        ele.addEventListener("click", onClick);

        function onClick(evt) {
            var page = evt.target.getAttribute("data-link-page");
            if (page) {
                evt.preventDefault();
                searchService.setPage(page);
                searchService.search();
            }
        }
    }
};

window.controllers.clickthrough = function(ele) {
    ele.addEventListener("click", function(evt) {
        evt.target.parentNode.click();
    });
}

window.controllers.footerPositioning = function(ele) {
    if (document.body.offsetHeight < window.innerHeight) {
        ele.style.position = "absolute";
        ele.style.bottom = "0";
        ele.style.width = "100%";
    }
}

