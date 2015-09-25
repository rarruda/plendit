window.controllers = window.controllers || {};

window.controllers.syncPayout = {
    callable: function(root) {
        init();

        function init() {
            var inputs = root.querySelectorAll("[data-payout-source]");
            for (var n = 0, e; e = inputs[n++];) {
                initInput(e);
            }
        }

        function initInput(source) {
            var destination = root.querySelector("[data-payout-for=\"" + source.getAttribute("name") + "\"]");
            var syncer = makeSyncer(source, destination);
            source.addEventListener('change', syncer);
            source.addEventListener('keyup', syncer);
            syncer();
        }

        function makeSyncer(source, destination) {
            return function(evt) {
                var price = parseFloat(source.value);
                if (isNaN(price)) {
                    destination.value = "";
                }
                else {
                    if (price == 0) {
                        destination.value = 0;
                    }
                    else {
                        destination.value = price * 1.10;
                    }
                }

            }
        }
    }
};