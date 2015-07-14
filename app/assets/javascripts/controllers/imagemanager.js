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
                .then(reRenderImages);
        }

        function reRenderImages(response) {
            ele.innerHTML = response.responseText;
        }
    }
};
