document.addEventListener("DOMContentLoaded", main);

function main() {
    var c = new Controllerator();
    c.registerInstance('eventbus', smokesignals.convert({}));
    c.registerInstance('tagbox', tagBox);
    c.registerInstance('xhr', xhr);
    c.scanControllers(controllers);
    c.scanServices(services);
    console.log("Running controllerator now!");
    c.run();
}
