window.addEventListener('load', main);

var controllers = {};

controllers.sideBarMap = {
    callable: function(ele) {
        console.log("jarra");
        var locString = ele.getAttribute('data-geolocation');
        if (locString) {
            var latLon = locString.split(',').map(function(e) { return parseFloat(e)});

            var center = {lat: latLon[0], lng: latLon[1]};

            var mapOptions = {
              center: center,
              zoom: 14
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


function main() {
    var c = new Controllerator(); 
    c.scanControllers(controllers);
    c.run();
}

