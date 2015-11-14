Dropzone.autoDiscover = false;
window.controllers.imageUploader = {
    dependencies: ["$element", "eventbus", "utils"],
    callable: function(ele, eventbus, utils) {
        var imagePath = ele.getAttribute('data-image-path');
        var template = ele.querySelector('[data-dropzone-template]').textContent;

        var dropzone = new Dropzone(ele, {
            url: imagePath,
            maxFilesize: 16, // Set the maximum file size to 16 MB
            paramName: 'ad_image[image]',
            addRemoveLinks: false,
            acceptedFiles: 'image/gif,image/jpeg,image/png',
            uploadMultiple: false,
            clickable: true,
            previewsContainer: '[data-dropzone-preview]',
            thumbnailWidth: 80,
            thumbnailHeight: 80,
            autoProcessQueue: true,
            parallelUploads: 2,
            previewTemplate: template,
            maxFiles: 100,
            init: onDropZoneInit
        });

        function onDropZoneInit() {
            this.on('sending', addCsrfToken);
            this.on('complete', onComplete);
            this.on('queuecomplete', onSuccess);
        }

        function addCsrfToken(formData, xhr) {
            var csrf = utils.getCsrfData();
            xhr.setRequestHeader('X-CSRF-Token', csrf.token);
        }

        function onComplete(file) {
            dropzone.removeFile(file);
        }

        function onSuccess() {
            eventbus.emit(eventbus.IMAGES_CHANGED)
        }
    }
};