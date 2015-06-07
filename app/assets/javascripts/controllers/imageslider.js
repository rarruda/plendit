window.controllers = window.controllers || {};

window.controllers.imageSlider = {
    callable: function(ele) {
        var slider = new IdealImageSlider.Slider('[data-gallery]');
        var thumbHolder = ele.querySelector("[data-thumbnails]");
        thumbHolder.addEventListener('click', selectImage);

        function selectImage(evt) {
            var index = parseInt(evt.target.getAttribute('data-thumbnail-for'));
            if (!isNaN(index) && index != null) {
                slider.gotoSlide(index);
            }
        }
    }
}

