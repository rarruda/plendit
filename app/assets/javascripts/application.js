// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .


////// THIS SHOULD BE IN AD_IMAGES.JS!!!!!!!!!!!!!!!!
////// DEFINETLY NOT HERE!!!

$(document).ready(function(){
    // disable auto discover
    Dropzone.autoDiscover = false;


    var dropzone = new Dropzone (".dropzone", {
        maxFilesize: 16, // Set the maximum file size to 16 MB
        paramName: "ad_image[image]", // Rails expects the file upload to be something like model[field_name]
        addRemoveLinks: true, // Don't show remove links on dropzone itself.
        // parameters that should probably be set after looking up the documentation: 
        // http://www.dropzonejs.com/#configuration-options
        // // previewsContainer  // how to show files to be uploaded.
        // // acceptedFiles      // list file types that are acceptable

        // autoProcessQueue: false, // to have a start upload button
        // uploadMultiple: true,    // upload all files at once (including the form data)
        parallelUploads: 100,
        maxFiles: 100,
        url: window.ad_images_json_url,
        init: function() {

//$('#pbutton').click(function(){
//     dropzone.processQueue(); // Tell Dropzone to process all queued files.
//});

          // load previously uploaded images from database via json call
          //var myDropzone = this;
          //ad_images_json_url must be set externally.
            $.getJSON(window.ad_images_json_url, function(data) { // get the json response
                $.each(data, function(key,value){ //loop through it
                    var mockFile = { name: value.name, size: value.size, type: value.type}; // here we get the file name and size as response 
                    dropzone.emit("addedfile", mockFile);
                    dropzone.emit("thumbnail", mockFile, value.url);
                    dropzone.emit("complete",  mockFile);
                    $(mockFile.previewTemplate).find('.dz-remove').attr('id', value.ad_image_id);
                });
            });
        }
    });


//    // You might want to show the submit button only when
//    // files are dropped here:
//    dropzone.on("addedfile", function() {
//      // Show submit button here and/or inform user to click it.
//    });

    dropzone.on("success", function(file, response){
            // find the remove button link of the uploaded file and give it an id
            // based of the ad_image_id response from the server
            $(file.previewTemplate).find('.dz-remove').attr('id', response.ad_image_id); //***should use response.delete_url
            // add the dz-success class (the green tick sign)
            $(file.previewElement).addClass("dz-success");
    })

    dropzone.on("removedfile", function(file, response){
               // grap the id of the uploaded file we set earlier
            var id = $(file.previewTemplate).find('.dz-remove').attr('id');

            // make a DELETE ajax request to delete the file
            $.ajax({
                type: 'DELETE',
                url: '/ad_images/' + id + '.json', //***this is super ugly (hardcoding urls). should use response.delete_url
                success: function(data){
                    console.log(data.message);
                }
            });
    })

});