document.addEventListener("DOMContentLoaded", main);

function main() {
    DetailsPolyfill.apply();

    var eventbus = smokesignals.convert({
        IMAGES_CHANGED: 'images_changed_event'
    });

    var c = new Controllerator();
    c.registerInstance('eventbus', eventbus);
    c.registerInstance('tagbox', tagBox);
    c.registerInstance('xhr', xhr);
    c.scanControllers(controllers);
    c.scanServices(services);
    console.log("Running controllerator now!");
    c.run();
}
