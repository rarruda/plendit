window.addEventListener('load', main);

var controllers = {};

controllers.sideBarMap = {
    callable: function(ele) {
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

controllers.resultMap = {
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

controllers.syncPayout = {
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

controllers.resultContainerSizeAdjuster = {
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

controllers.togglableFilters = {
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

controllers.imageSlider = {
    callable: function(ele) {
        var slider = new IdealImageSlider.Slider('[data-gallery]');
        var thumbHolder = ele.querySelector("[data-thumbnails]");
        thumbHolder.addEventListener('click', selectImage);

        function selectImage(evt) {
            var index = parseInt(evt.target.getAttribute('data-thumbnail-for'));
            if (!isNaN(index) && index != null) {
                slider.gotoSlide(index);
            }
        }
    }
}

function main() {
    var c = new Controllerator();
    c.registerInstance('eventbus', smokesignals.convert({}));
    c.scanControllers(controllers);
    c.run();
}

