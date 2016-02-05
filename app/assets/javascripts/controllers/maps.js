window.services = window.services || {};
window.controllers = window.controllers || {};

window.controllers.adMap = {
    callable: function(ele) {
        // map of [zoom level, radius] pairs
        var radiuses = {
            high: [14, 240],
            mid: [14, 440],
            low: [13, 1200],
            unk: [12, 2650],
            post_code: [12, 2650]
        }
        var locString = ele.getAttribute("data-geolocation");
        var precision = ele.getAttribute("data-geoprecision");

        var zoomAndRadius = radiuses[precision] || radiuses.unk;

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
                zoom: zoomAndRadius[0],
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
                radius: zoomAndRadius[1]
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
                scrollwheel: true,
                streetViewControl: false,
                mapTypeControl: false,
                center: bounds.getCenter(),
                zoom: searchData.map_bounds.zl,
                maxZoom: 18,
                minZoom: 2,
                styles: styles
            };

            var map = new google.maps.Map(ele, mapOptions);
            google.maps.event.addListener(map, 'idle', onAreaChanged);
            google.maps.event.addListener(map, 'click', onMapClick);

            var showHereButton = createShowHereButton();
            showHereButton.index = 1;
            map.controls[google.maps.ControlPosition.TOP_LEFT].push(showHereButton);

            var showEverywhereButton = createShowEverywhereButton();
            showEverywhereButton.index = 1;
            map.controls[google.maps.ControlPosition.TOP_LEFT].push(showEverywhereButton);
            return map;
        }

        function createShowHereButton() {
            var e = E("div", null, E("button.button.button-notprimary", {onclick: onShowHereClick}, "Søk der du er"));
            e.style.paddingTop = "12px";
            e.style.paddingLeft = "12px";
            return e;
        }

        function createShowEverywhereButton() {
            var e = E("div", null, E("button.button.button-notprimary", {onclick: onShowEverywhereClick}, "Søk i Norge"));
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

        function onShowEverywhereClick() {
            var ne = new google.maps.LatLng(70.919335, 29.739990);
            var sw = new google.maps.LatLng(58.047365, 4.163818);
            var bounds = new google.maps.LatLngBounds();
            bounds.extend(ne);
            bounds.extend(sw);
            map.fitBounds(bounds);
        }

        function onGeolocation(pos) {
            var location = {lat: pos.coords.latitude, lng: pos.coords.longitude};
            map.setCenter(location);
            map.setZoom(13);
        }

        function onGeoFail(err) {
            console.log("geolocation failed or not allowed", err);
        }

        function onLayoutChanged() {
            google.maps.event.trigger(map, 'resize');
        }

        function onAreaChanged() {
            var bounds = map.getBounds();

            var ne = bounds.getNorthEast();
            var sw = bounds.getSouthWest();
            var zl = map.getZoom();

            if (ne.lat() === sw.lat()) {
                // guard against weird resize bug where the map listens
                // for resizes on its own, which triggers idle, which
                // would trigger search, thus getting 0 hits, as the
                // map area is 0 pixels when map is hidden.
                // Hopefully this test is good enough.
                return;
            }


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
                    url: '/images/single_poi.png',
                    scaledSize: new google.maps.Size(45, 38),
                    // anchor: new google.maps.Point(32, 53)
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
                    url: '/images/multiple_poi.png',
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

            if (infoBox && infoBox.mid === id) {
                infoBox.close();
                infoBox = null;
                return;
            }
            else if (infoBox) {
                infoBox.close();
            }

            infoBox = makeInfoBox(renderSinglePopup(item), id);
            infoBox.open(map, marker);
        }

        function makeInfoBox(content, mid) {
            var ib = new InfoBox({
                content: content,
                disableAutoPan: true,
                maxWidth: 320,
                alignBottom: true,
                pixelOffset: new google.maps.Size(-150, -44),
                infoBoxClearance: new google.maps.Size(1, 1),
                closeBoxURL: ""
            });
            ib.mid = mid;
            return ib;
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
