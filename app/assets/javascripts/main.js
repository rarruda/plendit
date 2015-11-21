document.addEventListener("DOMContentLoaded", main);

function main() {
    if (!DetailsPolyfill.supportsDetails()) {
        DetailsPolyfill.apply();
    }

    var eventbus = smokesignals.convert({
        IMAGES_CHANGED: 'images_changed_event',
        AD_FORM_DIRTY: 'ad-form-dirty',
        AD_FORM_SAVE_OK: 'ad-form-save-ok',
        AD_FORM_SAVE_ERROR: 'ad-form-save-error'
    });

    var c = new Controllerator();
    c.registerInstance('eventbus', eventbus);
    c.registerInstance('xhr', xhr);
    c.registerInstance('createElement', createElement);
    c.registerInstance('Card', Card);
    c.registerInstance('mangoPay', mangoPay);
    c.registerInstance('utils', plenditUtils);
    c.scanControllers(controllers);
    c.scanServices(services);
    c.run();
}
