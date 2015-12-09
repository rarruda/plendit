window.controllers = window.controllers || {};
window.services = window.services || {};

window.services.responsive = {
    name: "responsive",
    callable: function() {

        function isGriddy() {
            return window.innerWidth > 767;
        }

        function isCollapsed() {
            return !isGriddy();
        }

        return {
            isGriddy: isGriddy,
            isCollapsed: isCollapsed
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
    dependencies: ["$element", "eventbus", "responsive"],
    callable: function(ele, eventBus, responsive) {
        window.addEventListener('resize', adjustHeight);
        adjustHeight();

        function adjustHeight() {
            var height = window.innerHeight - ele.offsetTop;
            var map = ele.querySelector("[data-map-view]")
            var hits = ele.querySelector("[data-hits-view]")

            if (responsive.isGriddy()) {
                hits.style.height = height + "px";
                hits.style.display = "block";
            }
            else {
                hits.style.height = null;
            }
            map.style.height = height + "px";
        }
    }
};

window.controllers.responsivePlaceholder = {
    callable: function(ele) {
        var original = ele.placeholder;
        window.addEventListener('resize', updatePlaceholder);
        updatePlaceholder()

        function updatePlaceholder() {
            ele.placeholder = window.innerWidth > 380 ? original : "Søk";
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
            var inputs = ele.querySelectorAll("input, select");
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

window.controllers.resultList = {
    dependencies: ["$element", "eventbus"] ,
    callable: function(ele, eventBus) {
        eventBus.on('new-search-result', onSearchResult);
        function onSearchResult(result) {
            if (result && result.markup != null) {
                ele.innerHTML = result.markup;
                ele.parentElement.scrollTop = 0;
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
            if (result.paging.total_count == 0) {
                ele.textContent = "Ingen treff."
            }
            else {
                var start = ((result.paging.current_page - 1) * result.paging.default_per_page) + 1;
                var end = Math.min(
                        result.paging.total_count,
                        result.paging.current_page * result.paging.default_per_page);
                ele.textContent = "Treff " + start + " - " + end + " av " + result.paging.total_count + ".";
            }
        }

        function onSearchStarted() {
            ele.textContent = "Søker…";
        }
    }
};

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
    dependencies: ["$element", "eventbus", "utils"],
    callable: function(ele, eventBus, utils) {
        var calCount = 1;
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

            if (dates.length == 0) {
                eventBus.emit(eventBus.BOOKING_DATES_CHANGED);
            }
            else if (dates.length == 2) {
                from_date.value = dates[0];
                to_date.value = dates[1];
                eventBus.emit(eventBus.BOOKING_DATES_CHANGED, dates[0], dates[1]);
            }
            else {
                from_date.value = dates[0];
                to_date.value = dates[0];
                eventBus.emit(eventBus.BOOKING_DATES_CHANGED, dates[0], dates[0]);
            }
        });

        getQueryDates();

        function getQueryDates() {
            var params = utils.queryParamsMap();
            var parts = [params.from_date, params.to_date].filter(function(e) { return e});

            if (parts.length == 1) { parts.push(parts[0]) }
            if (parts.length) {
                k.setSelected(parts.join(" - "));
            }
       }

    }
};

window.controllers.bookingPriceLoader = {
    dependencies: ["$element", "eventbus", "xhr"],
    callable: function(ele, eventBus, xhr) {
        eventBus.on(eventBus.BOOKING_DATES_CHANGED, onChanged);

        function onChanged(from, to) {
            console.log("woo", from, to);
        }

        function fetchEstimate() {}
    }
}

window.controllers.readOnlyCalendar = function(ele) {
    var calCount = 1;
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
    var calenderEle = ele.querySelector("[data-calendar]");
    var selected = "";

    function onViewChanged(yearOrWeek) {
        var now = moment();
        var then = this.viewStartDate.clone().add(1, "month");
        if (then.diff(now, 'years') > 0) { return false }
    }

    function onSelectionChanged() {
        var current = this.getSelected();
    }

    var bookedDatesEle = ele.querySelector('script[type="text/plain"]');
    if (bookedDatesEle) {
        selected = bookedDatesEle.textContent.trim();
    }

    var k = new Kalendae({
        attachTo: calenderEle,
        months: 1,
        mode: 'range',
        readOnly: false,
        weekStart: 1,
        direction: "today-future",
        blackout: selected,
        useYearNav: false,
        subscribe: {
            "view-changed": onViewChanged,
            "change": onSelectionChanged
        }
    });
};


window.controllers.videoTrigger = {
    dependencies: ['$element', 'responsive'],
    callable: function(ele, responsive) {
        if (responsive.isGriddy()) {
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

window.controllers.responsiveSearchResult = {
    dependencies: ["$element", "eventbus"],
    callable: function(ele, eventBus) {

        var map;
        var list;
        var listButton;
        var mapButton;

        init();

        function init() {
            list = document.querySelector("[data-hits-view]");
            map = document.querySelector("[data-map-view]");
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

window.controllers.helpToggler = function(ele) {
    Array.from(document.querySelectorAll("[data-help-label-for]"))
        .forEach(function(label) {
            var helpBox = document.querySelector("[data-help-text-for=\"" + label.getAttribute('data-help-label-for') + "\"]");
            label.addEventListener('click', function(e) {
                helpBox.classList.toggle('u-hidden');
            })
        });
}

window.controllers.adAutoSaver = {
    dependencies: ["$element", "xhr", "utils", "eventbus"],
    callable: function(ele, xhr, utils, eventbus) {
        var dirty = false;
        eventbus.on(eventbus.AD_FORM_SAVE_NOW, handleChange);
        ele.addEventListener("change", handleChange)

        function handleChange() {
            console.log("form is dirty");
            eventbus.emit(eventbus.AD_FORM_DIRTY);
            saveForm();
        }

        function saveForm() {
            xhr.xhrFormData(ele).then(handleSaveOk).catch(handleSaveError);
        }

        function handleSaveOk(xhr) {
            eventbus.emit(eventbus.AD_FORM_SAVE_OK, JSON.parse(xhr.responseText));
        }

        function handleSaveError(xhr) {
            var errors = JSON.parse(xhr.responseText);
            eventbus.emit(eventbus.AD_FORM_SAVE_ERROR, errors);
        }
    }
};

window.controllers.publishButton = {
    dependencies: ["$element", "utils", "eventbus"],
    callable: function(ele, utils, eventbus) {
        eventbus.on(eventbus.AD_FORM_SAVE_OK, handleSaveOk);
        eventbus.on(eventbus.AD_FORM_SAVE_ERROR, handleSaveError);
        eventbus.on(eventbus.AD_FORM_DIRTY, handleGotDirty);

        function handleGotDirty() {
            ele.disabled = true;
        }

        function handleSaveOk() {
            ele.disabled = false;
        }

        function handleSaveError() {
            console.log("nay");
        }
    }
};

window.controllers.adErrors = {
    dependencies: ["$element", "utils", "eventbus"],
    callable: function(ele, utils, eventbus) {
        ele.disabled = false;
        eventbus.on(eventbus.AD_FORM_SAVE_OK, handleSaveOk);
        eventbus.on(eventbus.AD_FORM_SAVE_ERROR, handleSaveError);
        eventbus.on(eventbus.AD_FORM_DIRTY, handleGotDirty);


        function handleGotDirty() {
            ele.disabled = true;
            ele.textContent = "Lagrer annonsen."
        }

        function handleSaveOk() {
            ele.disabled = false;
            ele.textContent = "Annonsen er lagret."
        }

        function handleSaveError(errors) {
            ele.textContent = "Annonsen er ikke lagret ennå. " + JSON.stringify(errors);
        }
    }
};

window.controllers.imageSubformController = {
    dependencies: ["$element", "xhr", "utils", "eventbus"],
    callable: function(ele, xhr, utils, eventbus) {
        eventbus.on(eventbus.IMAGES_CHANGED, reloadImages);
        var url = ele.getAttribute("data-url");
        ele.addEventListener("click", handleMakePrimaryClick)
        ele.addEventListener("click", function(e) {
            window.setTimeout(updatePrimality, 10);
        });
        ele.addEventListener("click", function() {
            window.setTimeout(function() {
                eventbus.emit(eventbus.AD_FORM_SAVE_NOW);
            }, 400);
        })

        updatePrimality();

        function reloadImages() {
            xhr
                .get(url)
                .then(onGotImageHtml)
                .then(updateUploadButton);
        }

        function onGotImageHtml(req) {
            ele.innerHTML = req.responseText;
        }

        function handleMakePrimaryClick(evt) {
            var e = evt.target;
            if (!e.hasAttribute("data-make-primary")) { return; }

            var thisOne = e.closest("[data-in-image]").parentElement;
            var firstOne = ele.querySelector("[data-in-image]").parentElement;

            if (thisOne !== firstOne) {
                firstOne.before(thisOne);
            }
            updateWeights();
            updatePrimality();
        }

        function updateUploadButton() {
            var hasNoImages = ele.querySelectorAll("[data-in-image]").length == 0;
            var button = document.querySelector("[data-upload-images-button]");
            if (button) {
                button.classList.toggle("button-primary", hasNoImages);
            }
        }

        function updateWeights() {
            Array.from(ele.querySelectorAll("[data-weight]"))
                 .forEach(function(e, n) {
                    e.value = n + 1;
                 });
        }

        function updatePrimality() {
            Array.from(ele.querySelectorAll("[data-in-image]"))
                 .filter(function(e) {
                    return e.parentElement.style.display != "none";
                 })
                 .forEach(function(e, n) {
                    e.classList.toggle("in-image--primary", n == 0);
                 });
        }
    }
};


window.controllers.updateMainPriceDetails = {
    dependencies: ["$element", "utils", "eventbus", "createElement"],
    callable: function(ele, utils, eventbus, E) {
        eventbus.on(eventbus.AD_FORM_SAVE_OK, onSaved);

        function onSaved(newState) {
            var payin = newState.main_payin_rule;
            var info =
                E('div', null,
                    E('div.main-price__row', null,
                        E('span.main-price__label', null, "Leiegebyr: "),
                        E('span.main-price__value', null, payin.total_fee)
                    ),
                    E('div.main-price__row', null,
                        E('i', null, "Inkluderer forsikring opp til "),
                        E('i', null, payin.max_insurance_coverage)
                    ),
                    E('div.main-price__row', null,
                        E('strong.main-price__label', null, "Utebetalt til deg: "),
                        E('strong.main-price__value', null, payin.payout_amount)
                    )
                );
            ele.innerHTML = info.innerHTML;
        }
    }
};


window.controllers.payinAdder = {
    dependencies: ["$element", "utils", "eventbus", "createElement", "xhr"],
    callable: function(ele, utils, eventbus, E, xhr) {
        var estimatesUrl = ele.getAttribute("data-estimate-url");
        var newRuleUrl = ele.getAttribute("data-new-rule-url");
        init();

        // eventbus.on(eventbus.AD_FORM_SAVE_OK, onSaved);
        function init() {
            ele.querySelector("[data-cancel]").addEventListener("click", onCancel);
            ele.querySelector("[data-save]").addEventListener("click", onSave);
            ele.querySelector("[data-name=days]").addEventListener("change", onChange);
            ele.querySelector("[data-name=price]").addEventListener("change", onChange);
        }

        function getInputs() {
            return {
                days: ele.querySelector("[data-name=days]").value,
                price: ele.querySelector("[data-name=price]").value
            };
        }

        function onChange() {
            var data = getInputs();
            if (data.price && data.price != "" && data.days && data.days != "") {
                xhr
                    .getJson(estimatesUrl + "?price=" + data.price + "&days=" + data.days)
                    .then(updateEstimate);
            }
        }

        function updateEstimate(payin) {
            if (!payin) { return; }

            var info =
                E('div', null,
                    E('div.main-price__row', null,
                        E('span.main-price__label', null, "Leiegebyr: "),
                        E('span.main-price__value', null, payin.total_fee)
                    ),
                    E('div.main-price__row', null,
                        E('i', null, "Inkluderer forsikring opp til "),
                        E('i', null, payin.max_insurance_coverage)
                    ),
                    E('div.main-price__row', null,
                        E('strong.main-price__label', null, "Utebetalt til deg: "),
                        E('strong.main-price__value', null, payin.payout_amount)
                    )
                );
            ele.querySelector("[data-estimate]").innerHTML = info.innerHTML;
            ele.querySelector("[data-save]").disabled = false;
        }

        function onSave() {
            var data = getInputs();
            xhr.postForm(newRuleUrl, data).then(clearAndClose).catch(reportSaveError);
        }

        function clearAndClose() {
            ele.querySelector("[data-name=days]").value = "";
            ele.querySelector("[data-name=price]").value = "";
            onCancel();
            eventbus.emit(eventbus.PRICE_MODEL_SAVED);
        }

        function reportSaveError(err) {
            console.log(err);
        }

        function onCancel() {
            ele.open = false;
        }
    }
};

window.controllers.secondaryPrices = {
    dependencies: ["$element", "utils", "eventbus", "createElement", "xhr"],
    callable: function(ele, utils, eventbus, E, xhr) {
        var getUrl = ele.getAttribute("data-fetch-url");
        var delUrl = ele.getAttribute("data-delete-url");
        ele.addEventListener("click", onClick);
        eventbus.on(eventbus.PRICE_MODEL_SAVED, onPriceModelsChanged);

        function onPriceModelsChanged() {
            xhr.get(getUrl).then(updateView);
        }

        function onClick(evt) {
            var ele = evt.target;
            if (ele.hasAttribute("data-delete")) {
                var id = ele.getAttribute('data-id');
                xhr.postForm(delUrl, {rule_id: ele.getAttribute("data-id")}).then(onPriceModelsChanged);
            }
        }

        function updateView(e) {
            ele.innerHTML = e.responseText;
        }
    }
};
