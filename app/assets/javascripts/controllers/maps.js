window.controllers = window.controllers || {};

window.controllers.adMap = {
    callable: function(ele) {
        var locString = ele.getAttribute('data-geolocation');

        if (locString) {
            var latLon = locString.split(',').map(function(e) { return parseFloat(e)});

            var center = {lat: latLon[0], lng: latLon[1]};

            var mapOptions = {
              streetViewControl: false,
              mapTypeControl: false,
              center: center,
              zoom: 14,
              maxZoom: 18,
              minZoom: 4,
              scrollwheel: false
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
    dependencies: ['$element', 'eventbus', 'searchService', 'utils'],
    callable: function(ele, eventBus, searchService, utils) {
        var searchData = searchService.getMostRecentSearchResult();
        if (!searchData) { return }

        eventBus.on('new-search-result', onSearchResult);

        var map = initMap(searchData);
        var infoWindow;
        var markers = []
        updateMarkers(searchData.groups);

        function initMap(searchData) {
            var center =  {
                lat: parseFloat(searchData.center.lat),
                lng: parseFloat(searchData.center.lon)
            }
            var zl = parseInt(searchData.zl)

            var mapOptions = {
                streetViewControl: false,
                mapTypeControl: false,
                center: center,
                zoom: zl,
                maxZoom: 18,
                minZoom: 4
            };

            var map = new google.maps.Map(ele, mapOptions);

            google.maps.event.addListener(map, 'center_changed', utils.debounce(onCenterChanged, 1000));
            google.maps.event.addListener(map, 'zoom_changed',   utils.debounce(onCenterChanged, 1000));

            return map;
        };

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
                    url: '/images/poi40.png',
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
                    path: google.maps.SymbolPath.CIRCLE,
                    strokeColor: "#1777B4",
                    strokeWeight: 6,
                    scale: 12,
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
            var div = document.createElement('div');
            div.className = "multi-marker-box";
            var innerMarkup = ids.forEach(function(id) { 
                div.appendChild(document.querySelector('[data-adid="'+ id +'"]').cloneNode(true));
            });
            
            if (infoWindow) { infoWindow.close(); }
            infoWindow = new google.maps.InfoWindow({
                content: div
            });
            infoWindow.open(map, marker);
        }

        function onMarkerClick(marker, id) {
            var hitEle = document.querySelector('[data-adid="'+ id +'"]');
            var hitEle = hitEle.cloneNode(true);
            if (infoWindow) { infoWindow.close(); }
            infoWindow = new google.maps.InfoWindow({
                content: hitEle
            });
            infoWindow.open(map, marker);
        }
    }
};
