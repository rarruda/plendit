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

            var c2 = new google.maps.Circle({
                strokeColor: '#2a96ff',
                strokeOpacity: 0.5,
                strokeWeight: 1,
                fillColor: '#2a96ff',
                fillOpacity: 0.3,
                map: map,
                center: center,
                radius: 30
            });
        }
    }
};

window.controllers.resultMap = {
    dependencies: ['$element', 'eventbus'],
    callable: function(ele, eventBus) {
        var jsonContainer = ele.querySelector("[data-location-info]");
        var searchData = JSON.parse(jsonContainer.textContent);
        jsonContainer.parentNode.removeChild(jsonContainer);;

        if (!searchData) { return }

        eventBus.on('new-search-result', onSearchResult);

        var map = initMap(searchData);
        var markers = [];
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
            return new google.maps.Map(ele, mapOptions);
        };

        function clearMarkers() {
            markers.forEach(function(e) { e.setMap(null); });
            markers = [];
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

            hits = hits.map(function(e) {
                return {lat: parseFloat(e.location.lat), lng: parseFloat(e.location.lon)}
            });

            var poiImg = {
                url: '/images/poi40.png',
                anchor: new google.maps.Point(10, 40)
            };

            hits.forEach(function(hit) {
                markers.push(new google.maps.Marker({
                    position: hit,
                    map: map,
                    title: 'Treff',
                    icon: poiImg
                }));
            });
        }

        function onSearchResult(hits) {
            updateMarkers(hits);
        }
    }
};
