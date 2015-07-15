window.controllers = window.controllers || {};

window.controllers.imageManager = {
    dependencies: ['$element', 'xhr', 'eventbus'],
    callable: function(ele, xhr, eventbus) {
        var imageManagerUrl = ele.getAttribute("data-image-manager-url");

        ele.addEventListener('submit', onSubmit);
        eventbus.on(eventbus.IMAGES_CHANGED, reloadImages);

        function onSubmit(ele) {
            ele.preventDefault();
            ajaxSubmitForm(ele.target);
        }

        function ajaxSubmitForm(form) {
            xhr
                .xhrFormData(form)
                .then(reloadImages)
                .catch(function(err) {
                    console.log("ARRAR!", err);
                });
        }

        function reloadImages() {
            return xhr
                .get(imageManagerUrl)
                .then(setTransparent)
                .then(sleep(300))
                .then(reRenderImages)
                .then(setOpaque)
        }

        function reRenderImages(response) {
            ele.innerHTML = response.responseText;
        }

        function setTransparent(e) {
            ele.classList.add('u-transparent');
            return e;
        }

        function setOpaque(e) {
            ele.classList.remove('u-transparent');
            return e
        }

        function sleep(ms) {
            return function(e) {
                return new Promise(function(resolve, reject) {
                    window.setTimeout(function() { resolve(e); }, ms);
               });
            }
        }
    }
};