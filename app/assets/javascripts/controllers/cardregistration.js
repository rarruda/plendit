window.controllers = window.controllers || {};

window.controllers.cardInputter = {
    dependencies: ["$element", "Card", "mangoPay"],
    callable: function(ele, Card, mangoPay) {
        var form;

        //mangoPay.cardRegistration.baseURL = "https://api.sandbox.mangopay.com";
        //mangoPay.cardRegistration.clientId = {your-client-id};

        //mangoPay.cardRegistration.init({
        //    cardRegistrationURL: {CardRegistrationURL property},
        //    preregistrationData: {PreregistrationData property},
        //    accessKey: {AccessKey property},
        //    Id: {Id property}
        //});

        init();

        function init() {
            form = ele.querySelector('form');
            var c = ele.querySelector("[data-card-holder]");

            var card = new Card({
                form: form,
                container: c,
                width: 400,
                placeholders: {
                    name: 'Fullt navn'
                }
            });

            form.addEventListener("submit", onSubmit);
        }

        function onSubmit(evt) {
            evt.preventDefault();
            var cardInfo = getCardInfo();
            var errors = getCardInfoErrors(cardInfo);
            if (errors.length) {
                renderErrors(errors);
            }
            else {
                console.log("woo. submit it to the max.");
            }
        }

        function cardRegistrationPromise(cardData) {
            return new Promise(function(resolve, reject) {
                mangoPay.cardRegistration.registerCard(cardData, resolve, reject);
            });
        }

        function renderErrors(errors) {
            console.log(errors);
        }

        function getCardInfoErrors(cardInfo) {
            var errors = [];
            if (!cardInfo.cardNumber) {
                errors.push("MISSING_CARD_NUMBER");
            }

            if (!cardInfo.cardCvx) {
                errors.push("MISSING_CVX_NUMBER");
            }

            if (!cardInfo.cardType) {
                errors.push("UNKNOWN_CARD_TYPE");
            }

            if (!cardInfo.cardExpirationDate) {
                errors.push("MISSING_EXPIRATION_DATE");
            }

            return errors;
        }

        function getCardInfo() {
            var cnum = (form.number.value || "").replace(/\s/g, '');
            return {
                cardNumber: cnum,
                cardExpirationDate: form.expiry.value,
                cardCvx: form.cvc.value,
                cardType: typeFromCardNumber(cnum)
            }
        }

        function typeFromCardNumber(number) {
            number = number || "";
            var re = {
                electron: /^(4026|417500|4405|4508|4844|4913|4917)\d+$/,
                maestro: /^(5018|5020|5038|5612|5893|6304|6759|6761|6762|6763|0604|6390)\d+$/,
                dankort: /^(5019)\d+$/,
                interpayment: /^(636)\d+$/,
                unionpay: /^(62|88)\d+$/,
                visa: /^4[0-9]{12}(?:[0-9]{3})?$/,
                mastercard: /^5[1-5][0-9]{14}$/,
                amex: /^3[47][0-9]{13}$/,
                diners: /^3(?:0[0-5]|[68][0-9])[0-9]{11}$/,
                discover: /^6(?:011|5[0-9]{2})[0-9]{12}$/,
                jcb: /^(?:2131|1800|35\d{3})\d{11}$/
            };

            if (re.electron.test(number)) {
                return null;
            } else if (re.maestro.test(number)) {
                return 'MAESTRO';
            } else if (re.dankort.test(number)) {
                return null;
            } else if (re.interpayment.test(number)) {
                return null;
            } else if (re.unionpay.test(number)) {
                return null;
            } else if (re.visa.test(number)) {
                return 'CB_VISA_MASTERCARD';
            } else if (re.mastercard.test(number)) {
                return 'CB_VISA_MASTERCARD';
            } else if (re.amex.test(number)) {
                return 'null';
            } else if (re.diners.test(number)) {
                return 'DINERS';
            } else if (re.discover.test(number)) {
                return null;
            } else if (re.jcb.test(number)) {
                return null;
            } else {
                return undefined;
            }
        }
    }
};


