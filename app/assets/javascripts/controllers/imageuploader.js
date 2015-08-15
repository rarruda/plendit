Dropzone.autoDiscover = false;
window.controllers.imageUploader = {
    dependencies: ["$element", "eventbus"],
    callable: function(ele, eventbus) {
        var imagePath = ele.getAttribute("data-image-path");
        var template = ele.querySelector("[data-dropzone-template]").textContent;

        var dropzone = new Dropzone(ele.querySelector("form"), {
            maxFilesize: 16, // Set the maximum file size to 16 MB
            paramName: "ad_image[image]", // Rails expects the file upload to be something like model[field_name]
            addRemoveLinks: false,
            acceptedFiles: "image/gif,image/jpeg,image/png",
            uploadMultiple: false,    // upload all files at once (including the form data)
            clickable: true,
            previewsContainer: "[data-dropzone-preview]",
            thumbnailWidth: 80,
            thumbnailHeight: 80,
            autoProcessQueue: true,
            parallelUploads: 2,
            previewTemplate: template,
            maxFiles: 100,
            init: onDropZoneInit
        });

        function onDropZoneInit() {
            this.on('complete', onComplete);
            this.on("removedfile", onRemovedfile);
            this.on("uploadprogress", logger("uploadprogress"));
            this.on("totaluploadprogress", logger("totaluploadprogress"));
            this.on("queuecomplete", logger("queuecomplete"));
            this.on("successmultiple", logger("successmultiple"));
            this.on("success", logger("success"));
            this.on("success", onSuccess);
            this.on("progress", logger("progress"));
        }

        function onComplete(file) {
            dropzone.removeFile(file);
        }

        function logger(name) {
            return function(a,b,c,d) { console.log(name, a,b,c,d) };
        }

        function onRemovedfile(file) {
        }

        function onSuccess() {
            eventbus.emit(eventbus.IMAGES_CHANGED)
        }
    }
};
