window.controllers = window.controllers || {};

window.controllers.adMap = {
    callable: function(ele) {
        var locString = ele.getAttribute('data-geolocation');

        if (locString) {
            var latLon = locString.split(',').map(function(e) { return parseFloat(e)});

            var center = {lat: latLon[0], lng: latLon[1]};

            var styles = [
                {
                    "featureType": "poi.business",
                    "stylers": [
                        { "visibility": "off" }
                    ]
                },{
                    "featureType": "transit.station",
                    "stylers": [
                        { "visibility": "off" }
                    ]
                },{
                    "featureType": "poi.place_of_worship",
                    "stylers": [
                        { "visibility": "off" }
                    ]
                },{
                    "featureType": "poi.attraction",
                    "stylers": [
                        { "visibility": "off" }
                    ]
                },{
                    "featureType": "poi.sports_complex",
                    "stylers": [
                        { "visibility": "off" }
                    ]
                },{
                    "elementType": "labels.icon",
                    "stylers": [
                        { "visibility": "off" }
                    ]
                }
            ];

            var mapOptions = {
                streetViewControl: false,
                mapTypeControl: false,
                center: center,
                zoom: 14,
                maxZoom: 18,
                minZoom: 4,
                scrollwheel: false,
                styles: styles
            };

            var map = new google.maps.Map(ele, mapOptions);

            var c1 = new google.maps.Circle({
                strokeColor: '#2a96ff',
                strokeOpacity: 0.8,
                strokeWeight: 1,
                fillColor: '#2a96ff',
                fillOpacity: 0.2,
                map: map,
                center: center,
                radius: 240
            });
        }
    }
};

window.controllers.resultMap = {
    dependencies: ['$element', 'eventbus', 'searchService', 'utils', 'createElement'],
    callable: function(ele, eventBus, searchService, utils, E) {
        var searchData = searchService.getMostRecentSearchResult();
        if (!searchData) { return }

        eventBus.on('new-search-result', onSearchResult);
        eventBus.on('layout-changed', onLayoutChanged);

        var map = initMap(searchData);
        var infoBox;
        var markers = [];
        updateMarkers(searchData.groups);

        function initMap(searchData) {
            var bounds = new google.maps.LatLngBounds();
            bounds.extend(new google.maps.LatLng(searchData.map_bounds.ne_lat, searchData.map_bounds.ne_lon));
            bounds.extend(new google.maps.LatLng(searchData.map_bounds.sw_lat, searchData.map_bounds.sw_lon));
            // todo : get zoomlevel back
            //var zl = parseInt(searchData.zl);

            var styles = [
                {
                    "featureType": "poi.business",
                    "stylers": [
                        { "visibility": "off" }
                    ]
                },{
                    "featureType": "transit.station",
                    "stylers": [
                        { "visibility": "off" }
                    ]
                },{
                    "featureType": "poi.place_of_worship",
                    "stylers": [
                        { "visibility": "off" }
                    ]
                },{
                    "featureType": "poi.attraction",
                    "stylers": [
                        { "visibility": "off" }
                    ]
                },{
                    "featureType": "poi.sports_complex",
                    "stylers": [
                        { "visibility": "off" }
                    ]
                },{
                    "elementType": "labels.icon",
                    "stylers": [
                        { "visibility": "off" }
                    ]
                }
            ];

            var mapOptions = {
                streetViewControl: false,
                mapTypeControl: false,
                center: bounds.getCenter(),
                zoom: 13,
                maxZoom: 18,
                minZoom: 4,
                styles: styles
            };

            var map = new google.maps.Map(ele, mapOptions);
            google.maps.event.addListener(map, 'center_changed', utils.debounce(onCenterChanged, 1000));
            google.maps.event.addListener(map, 'zoom_changed', utils.debounce(onCenterChanged, 1000));
            google.maps.event.addListener(map, 'center_changed', notifyWillChange);
            google.maps.event.addListener(map, 'zoom_changed', notifyWillChange);
            google.maps.event.addListener(map, 'click', onMapClick);

            var showHereButton = createShowHereButton();
            showHereButton.index = 1;
            map.controls[google.maps.ControlPosition.TOP_LEFT].push(showHereButton);
            return map;
        }

        function createShowHereButton() {
            var e = E("div", null, E("button.button.button-notprimary", {onclick: onShowHereClick}, "Søk her"));
            e.style.paddingTop = "12px";
            e.style.paddingLeft = "12px";
            return e;
        }

        function onMapClick() {
            if (infoBox) {
                infoBox.close();
                infoBox = null;
            }
        }

        function onShowHereClick() {
            if ("geolocation" in navigator) {
                utils.geoPromise().then(onGeolocation).catch(onGeoFail);
            }
        }

        function onGeolocation(pos) {
            var location = {lat: pos.coords.latitude, lng: pos.coords.longitude};
            map.setCenter(location);
            map.setZoom(14);
        }

        function onGeoFail() {
            console.log("geolocation failed or not allowed");
        }

        function notifyWillChange() {
            eventBus.emit('map-will-change');
        }

        function onLayoutChanged() {
            google.maps.event.trigger(map, 'resize');
        }

        function onCenterChanged() {
            var bounds = map.getBounds();
            var ne = bounds.getNorthEast();
            var sw = bounds.getSouthWest();
            var zl = map.getZoom();

            searchService.setZoom({
                zl: zl
            });
            searchService.setBounds({
                ne_lat: ne.lat(),
                ne_lon: ne.lng(),
                sw_lat: sw.lat(),
                sw_lon: sw.lng()
            });
            searchService.search();
        }

        function clearMarkers() {
            markers.forEach(function(e) { e.setMap(null); });
            markers = [];
        }

        function createSingleMarker(location, id) {
            var marker = new google.maps.Marker({
                position: {lat: parseFloat(location.lat), lng: parseFloat(location.lon)},
                icon: {
                    url: '/images/single_stroke.png',
                    scaledSize: new google.maps.Size(45, 40),
                    anchor: new google.maps.Point(10, 40)
                },
                map: map
            });

            google.maps.event.addListener(marker, 'click', onMarkerClick.bind(this, marker, id));
            markers.push(marker);
        }

        function createGroupMarker(location, ids) {
            var marker = new google.maps.Marker({
                position: {lat: parseFloat(location.lat), lng: parseFloat(location.lon)},
                icon: {
                    url: '/images/multiple_stroke.png',
                    scaledSize: new google.maps.Size(45, 40),
                    anchor: new google.maps.Point(10, 40)
                },
                map: map
            });

            google.maps.event.addListener(marker, 'click', onMultiMarkerClick.bind(this, marker, ids));
            markers.push(marker);
        }

        function updateMarkers(groups) {
            clearMarkers();
            groups.forEach(function(group) {
                if (group.hits.length > 1) {
                    createGroupMarker(group.location, group.hits);
                }
                else {
                    createSingleMarker(group.location, group.hits[0]);
                }
            });
        }

        function onSearchResult(result) {
            updateMarkers(result.groups);
        }

        function onMultiMarkerClick(marker, ids) {
            var lastSearch = searchService.getMostRecentSearchResult();
            var items = ids.map(function(e) {
                return lastSearch.ads[e];
            });

            console.log(items);

            var multiContent = E('div.multi-marker-box', null,
                items.map(renderSinglePopup)
            );

            if (infoBox) { infoBox.close(); }

            infoBox = makeInfoBox(multiContent);
            infoBox.open(map, marker);
        }

        function onMarkerClick(marker, id) {
            var searchItems = searchService.getMostRecentSearchResult();
            var item = searchItems.ads[id];

            if (infoBox) { infoBox.close(); }
            infoBox = makeInfoBox(renderSinglePopup(item));
            infoBox.open(map, marker);
        }

        function makeInfoBox(content) {
            return new InfoBox({
                content: content,
                disableAutoPan: true,
                maxWidth: 320,
                alignBottom: true,
                pixelOffset: new google.maps.Size(-150, -44),
                infoBoxClearance: new google.maps.Size(1, 1),
                closeBoxURL: ""
                //closeBoxMargin: "12px 4px 2px 2px"
                //closeBoxURL: "http://www.google.com/intl/en_us/mapfiles/close.gif",
            });
        }

        function renderSinglePopup(item) {
            return E('div.result-infoview', null,
                E('a.result-infoview__body', {href: item.listing_url},
                    E('div.result-infoview__image-holder', null,
                        E('img.result-infoview__image', {src: item.image_url})),
                    E('h5.result-infoview__title', null, item.title)
                )
            );
            return ele;
        }
    }
};
