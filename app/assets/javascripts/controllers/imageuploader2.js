Dropzone.autoDiscover = false;
window.controllers.imageUploader = {
    callable: function(ele) {
        var imagePath = ele.getAttribute("data-image-path");
        var template = ele.querySelector("[data-dropzone-template]").textContent;

        var dropzone = new Dropzone(ele.querySelector("form"), {
            maxFilesize: 16, // Set the maximum file size to 16 MB
            paramName: "ad_image[image]", // Rails expects the file upload to be something like model[field_name]
            addRemoveLinks: false,
            // parameters that should probably be set after looking up the documentation: 
            // http://www.dropzonejs.com/#configuration-options
            // // acceptedFiles      // list file types that are acceptable
            // autoProcessQueue: false, // to have a start upload button
            uploadMultiple: false,    // upload all files at once (including the form data)
            clickable: true,
            previewsContainer: "[data-dropzone-preview]",
            thumbnailWidth: 80,
            thumbnailHeight: 80,
            autoProcessQueue: true,
            parallelUploads: 100,
            maxFiles: 100,
            //url: imagePath,
            previewTemplate: template,
            init: onDropZoneInit
        });

        function onDropZoneInit() {
            this.on("removedfile", onRemovedfile);
            this.on("uploadprogress", logger("uploadprogress"));
            this.on("totaluploadprogress", logger("totaluploadprogress"));
            this.on("queuecomplete", logger("queuecomplete"));
            this.on("successmultiple", logger("successmultiple"));
            this.on("success", logger("success"));
            this.on("progress", logger("progress"));
        }

        function logger(name) {
            return function(a,b,c,d) { console.log(name, a,b,c,d) };
        }

        function onRemovedfile(file) {
        }

        function onSuccess(a,b,c) {
            console.log("success");
            // fixme: get the delete URL out of it, store it in a dict in
            // controller so we always have the delete url and friends
        }
    }
};
