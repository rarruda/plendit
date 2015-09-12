window.controllers = window.controllers || {};

window.controllers.cardRegistration = {
    dependencies: ['$element', 'eventbus', 'mangoPay'],
    callable: function(ele, eventbus, mangoPay) {

        function getFormData(form) {
            var formData = {};
            Array
                .from(form.querySelectorAll("input"))
                .forEach(function(e) {
                    formData[e.name] = e.value;
                });
        }

        function cardRegistrationPromise(cardData) {
            return new Promise(function(resolve, reject) {
                mangoPay.cardRegistration.registerCard(cardData, resolve, reject);
            });
        }
    }
};

