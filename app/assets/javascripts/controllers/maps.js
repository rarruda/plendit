window.controllers = window.controllers || {};

window.controllers.adMap = {
    callable: function(ele) {
        var locString = ele.getAttribute('data-geolocation');

        if (locString) {
            var latLon = locString.split(',').map(function(e) { return parseFloat(e)});

            var center = {lat: latLon[0], lng: latLon[1]};

            var mapOptions = {
              center: center,
              zoom: 15,
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
    dependencies: ['$element', 'eventbus', 'searchService'],
    callable: function(ele, eventBus, searchService) {
        var searchData = searchService.getMostRecentSearchResult();
        if (!searchData) { return }

        eventBus.on('new-search-result', onSearchResult);

        var map = initMap(searchData);
        var clusterer = new MarkerClusterer(map, [], {gridSize: 50, maxZoom: 12});
        var infoWindow;
        updateMarkers(searchData.hits);

        function initMap(searchData) {
            var center =  {
                lat: parseFloat(searchData.center.lat),
                lng: parseFloat(searchData.center.lon)
            }

            var mapOptions = {
                center: center,
                zoom: 12
            };

            var map = new google.maps.Map(ele, mapOptions);

            google.maps.event.addListener(map, 'center_changed', debounce(onCenterChanged, 1000));
            return map;
        };

        function onCenterChanged() {
            var bounds = map.getBounds();
            var ne = bounds.getNorthEast();
            var sw = bounds.getSouthWest();
            searchService.setBounds({
                ne_lat: ne.lat(),
                ne_lon: ne.lng(),
                sw_lat: sw.lat(),
                sw_lon: sw.lng()
            });
        }

        function clearMarkers() {
            clusterer.clearMarkers();
        }

        function updateMarkers(result) {
            var hits = result.hits || result; // hack. Fix in serialization
            clearMarkers();
            hits = hits.filter(function(e) {
                if (!e || !e.location) {
                    console.log("Missing lat long for search result item!");
                    return false;
                }
                return true;
            });

            var poiImg = {
                url: '/images/poi40.png',
                anchor: new google.maps.Point(10, 40)
            };

            var markers = hits.map(function(hit) {
                return new google.maps.Marker({
                    position: {lat: parseFloat(hit.location.lat), lng: parseFloat(hit.location.lon)},
                    title: 'Treff',
                    icon: poiImg,
                    adId: hit.id
                });
            });

            markers.forEach(function(marker) {
                google.maps.event.addListener(marker, 'click', function() {
                    onMarkerClick(marker);
                });
            });

            clusterer.addMarkers(markers);
        }

        function onSearchResult(hits) {
            updateMarkers(hits);
        }

        function debounce(func, wait, immediate) {
            var timeout;
            return function() {
                var context = this, args = arguments;
                var later = function() {
                    timeout = null;
                    if (!immediate) func.apply(context, args);
                };
                var callNow = immediate && !timeout;
                clearTimeout(timeout);
                timeout = setTimeout(later, wait);
                if (callNow) func.apply(context, args);
            };
        };

        function onMarkerClick(marker) {
            var hitEle = document.querySelector('[data-adid="'+ marker.adId +'"]');
            var hitEle = hitEle.cloneNode(true);
            if (infoWindow) { infoWindow.close(); }
            infoWindow = new google.maps.InfoWindow({
                content: hitEle
            });
            infoWindow.open(map, marker);
        }


    }
};
