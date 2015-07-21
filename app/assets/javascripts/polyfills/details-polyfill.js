window.DetailsPolyfill = (function() {
    "use strict";

    var styleEle;

    function supportsDetails() {
        return document.createElement("details").open !== undefined;
    }

    function installStylesheet() {
        if (styleEle && styleEle.parentNode) {
            return;
        }

        styleEle = document.createElement("style");
        styleEle.textContent = [
            "/* Inserted by DetailsPolyfill */",
            "details, summary {",
            "    display: block;",
            "}",
            "details:not([open]) > :not(summary) {",
            "    display: none;",
            "}"
        ].join("\n");
        document.head.appendChild(styleEle);
    }

    function handleClick(event) {
        event.preventDefault();
        var ele = event.target.closest("details");
        ele.open = !ele.hasAttribute("open");
    }

    function handleKeydown(event) {
        if (event.keyCode == 13 /* Enter */ || event.keyCode == 32 /* Space */) {
            event.stopPropagation();
            event.preventDefault();
            event.target.click();
        }
    }

    function open(ele) {
        ele.setAttribute("open", "");
        ele.querySelector("summary").setAttribute("aria-expanded", "true");
    }

    function close(ele) {
        ele.removeAttribute("open");
        ele.querySelector("summary").setAttribute("aria-expanded", "false");
    }

    // This makes it possible to hide elements initially by specifying `style="display: none"`
    // and `data-hidden`, to avoid FOUC
    function showHiddenElements(ele) {
        var eles = ele.querySelectorAll("[data-hidden]");
        Array.from(eles).forEach(function(ele) {
            ele.style.removeProperty("display");
        });
    }

    function polyfill(ele) {
        if (ele.hasDetailsPolyfill) {
            return;
        }

        // Quickfix: this throws in iOS 7, so wrap in try/catch for now
        try {
            Object.defineProperty(ele, "open",
                {
                    get: function() {
                        return this.hasAttribute("open");
                    },
                    set: function(value) {
                        if (value) {
                            open(this);
                        }
                        else {
                            close(this);
                        }
                    }
                }
            );
        } catch(e) {}

        var randomId = "detailspolyfill_" + ((Math.random() * 0xFFFFFFF) | 0);

        ele.hasDetailsPolyfill = true;
        ele.open = ele.hasAttribute("open");
        ele.id = randomId;
        ele.setAttribute("role", "group");

        var summaryEle = ele.querySelector("summary");
        if (!summaryEle) {
            summaryEle = document.createElement("summary");
            summaryEle.textContent = "Details";
            ele.prepend(summaryEle);
        }

        if (!summaryEle.hasAttribute("tabindex")) {
            summaryEle.tabIndex = "0";
        }

        summaryEle.setAttribute("role", "button");
        summaryEle.setAttribute("aria-controls", randomId);

        summaryEle.addEventListener("click", handleClick);
        summaryEle.addEventListener("keydown", handleKeydown);
    }

    function apply() {
        var eles = Array.from(document.querySelectorAll("details"));
        if (!supportsDetails()) {
            installStylesheet();
        }
        // For now, polyfill in all browsers since accessibility support is poor.
        eles.forEach(polyfill);
        eles.forEach(showHiddenElements);
    }

    return {
        apply: apply,
        supportsDetails: supportsDetails
    };

})();