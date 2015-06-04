window.controllers = window.controllers || {};

Dropzone.autoDiscover = false;
window.controllers.dropzone = {
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
            // uploadMultiple: true,    // upload all files at once (including the form data)
            clickable: true,
            previewsContainer: "[data-dropzone-preview]",
            thumbnailWidth: 80,
            thumbnailHeight: 80,
            autoProcessQueue: true,
            parallelUploads: 100,
            maxFiles: 100,
            url: imagePath,
            previewTemplate: template,
            init: onDropZoneInit
        });

        function onDropZoneInit() {
            this.on("success", onSuccess);
            this.on("removedfile", onRemovedfile);
            fetchCurrentImages();
        }

        function fetchCurrentImages() {
            xhr
                .getJson(imagePath)
                .then(onGotImages);
        }

        function onGotImages(images) {
            images
                .map(makeMockFile)
                .forEach(emitEvents)
        }

        function emitEvents(image) {
            dropzone.emit("addedfile", image);
            dropzone.emit("thumbnail", image, image.url);
            dropzone.emit("complete",  image);
        }

        function makeMockFile(item) {
            return { 
                name: item.name, size: item.size, type: item.type,
                url: item.url, id: item.ad_image_id, delete_url: item.delete_url
            };
        }

        function onRemovedfile(file) {
            if (file.delete_url) {
                xhr
                    .del(file.delete_url)
                    .then(function() {
                        console.log('success!')
                    })
                    .catch(function(err) {
                        console.log("deletion failed!", err);
                    });                
            }

        }

        function onSuccess(a,b,c) {
            console.log(a,b,c);
            // fixme: get the delete URL out of it, store it in a dict in
            // controller so we always have the delete url and friends
        }
    }

};
