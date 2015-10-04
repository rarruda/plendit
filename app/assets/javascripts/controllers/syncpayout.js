window.controllers = window.controllers || {};

window.controllers.payoutFetcher = {
    dependencies: ['$element', 'utils'],
    callable: function(ele, utils) {
        var insuranceBox = ele.querySelector("[data-insurance]");
        var priceInput = ele.querySelector("[data-price]");
        var calculatedPriceOutput = ele.querySelector("[data-payout]");
        var category = ele.getAttribute('data-category');
        var priceUrl = ele.getAttribute('data-price-url');
        var callback = utils.debounce(fetchPayout, 700);
        var lastPrice = "";
        var lastInsurance = "";

        [insuranceBox, priceInput].filter(function(e) { return e }).forEach(function(e) {
            e.addEventListener('change', callback);
            e.addEventListener('keyup', callback);
            e.addEventListener('blur', callback);
        });

        function fetchPayout(evt) {
            if (lastPrice != priceInput.value || (insuranceBox && lastInsurance !== insuranceBox.checked)) {
                lastPrice = priceInput.value;
                lastInsurance = insuranceBox ? insuranceBox.checked : null;
                var url = priceUrl + "?price=" + lastPrice + "&insurance=" + lastInsurance + "&category=" + category;
                xhr.get(url).then(updatePostalPlace);
            }
        }

        function updatePostalPlace(xhr) {
            calculatedPriceOutput.value = xhr.responseText;
        }
    }
}