window.addEventListener("load", main);

function main() {
    var c = new Controllerator();
    c.registerInstance('eventbus', smokesignals.convert({}));
    c.registerInstance('tagbox', tagBox);
    c.scanControllers(controllers);
    c.scanServices(services);
    console.log("Running controllerator now!");
    c.run();
}
