(function(global) {

    global.tagBox = function(container, opts) {
        opts = opts || {};
        container.addEventListener('click', onClick);
        var input = document.createElement('input');
        input.className = opts.inputClassName || "";
        container.appendChild(input);
        input.addEventListener("keyup", onKeyup);
        input.addEventListener("blur", onBlur);
        var bomped = false;

        function onClick(evt) {
            var ele = evt.target;
            if (ele.hasAttribute('data-tag')) {
                ele.parentNode.removeChild(ele);
                notify();
            }
            else {
                input.focus();
            }
        }

        function sanitizeTag(value) {
            return value.replace(/[^a-z0-9_-]/g, '');
        }

        function tagIsValid(value) {
            return value && value.length > 1;
        }

        function onBlur(evt) {
            saveTag(evt.target);
        }

        function onKeyup(evt) {
            // console.log(evt.keyCode)
            var input = evt.target;
            if (evt.keyCode == 188 || evt.keyCode == 32 || evt.keyCode == 13) {
                saveTag(input);
            }
            else if (evt.keyCode == 8) {
                if (input.value == "" && bomped) {
                    bomped = false;
                    unSaveTag(input);
                }
                else if (input.value == "") {
                    bomped = true;
                }
                else {
                    bomped = false;
                }
            }
            else {
                bomped = false;
            }
        }

        function unSaveTag(input) {
            var tags = input.parentNode.querySelectorAll("span:last-of-type");
            var lastTag = tags[tags.length - 1];

            if (lastTag) {
                input.value = lastTag.textContent;
                lastTag.parentNode.removeChild(lastTag);
            }
            notify();
        }

        function saveTag(input) {
            var s = sanitizeTag(input.value);
            input.value = "";
            if (tagIsValid(s)) {
                input.parentNode.insertBefore(makeTagEle(sanitizeTag(s)), input);
            }
            bomped = true;
            notify()
        }

        function makeTagEle(value) {
            var e = document.createElement("span");
            e.className = opts.tagClassName || "";
            e.setAttribute("data-tag", "");
            e.textContent = value;
            return e;
        }

        function notify() {
            if (opts.onChange) {
                var tags = Array.prototype.slice
                    .call(container.querySelectorAll("[data-tag]"))
                    .map(function(e) { return e.textContent });
                opts.onChange(tags);
            }
        }

    }
})(window);
