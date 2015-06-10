window.addEventListener("load", main);

function main() {
    var c = new Controllerator();
    c.registerInstance('eventbus', smokesignals.convert({}));
    c.scanControllers(controllers);
    c.scanServices(services);
    console.log("Running controllerator now!");
    c.run();
}
