window.controllers = window.controllers || {};

window.controllers.adMap = {
    callable: function(ele) {
        var locString = ele.getAttribute('data-geolocation');

        if (locString) {
            var latLon = locString.split(',').map(function(e) { return parseFloat(e)});

            var center = {lat: latLon[0], lng: latLon[1]};

            var mapOptions = {
              center: center,
              zoom: 15
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
    callable: function(ele) {
        var jsonContainer = ele.querySelector("[data-location-info]");
        var searchData = JSON.parse(jsonContainer.textContent);
        jsonContainer.parentNode.removeChild(jsonContainer);;

        if (!searchData) { return }

        // fixme: this should happen in ruby land
        searchData.center = {
            lat: parseFloat(searchData.center.lat),
            lng: parseFloat(searchData.center.lon)
        }

        searchData.hits = searchData.hits.filter(function(e) {
            if (!e) {
                console.log("Missing lat long for search result item!");
                return false;
            }
            return true;
        });

        searchData.hits = searchData.hits.map(function(e) {
            return {lat: parseFloat(e.lat), lng: parseFloat(e.lon)}
        });

        var mapOptions = {
            center: searchData.center,
            zoom: 12
        };
        var map = new google.maps.Map(ele, mapOptions);

        var poiImg = {
            url: '/images/poi40.png',
            anchor: new google.maps.Point(10, 40)
        };

        searchData.hits.forEach(function(hit) {
            var marker = new google.maps.Marker({
                position: hit,
                map: map,
                title: 'Treff',
                icon: poiImg
            });

        });
    }
};
