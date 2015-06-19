(function(global) {

    global.tagBox = function(container, opts) {
        opts = opts || {};
        container.addEventListener('click', onClick);
        var input = document.createElement('input');
        input.className = opts.inputClassName || "";
        container.appendChild(input);
        input.addEventListener("keyup", onKeyup);
        input.addEventListener("blur", onBlur);
        input.addEventListener("keypress", cancelEnter);
        var bomped = false;

        if (opts.tags) {
            opts.tags
                .filter(function(e) { return !!e })
                .forEach(insertTag);
        }

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

        function cancelEnter(evt) {
            if (evt.keyCode == 13) {
                evt.preventDefault();
            }
        }

        function sanitizeTag(value) {
            return value.replace(/\s/ig, '');
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
                evt.preventDefault();
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
                insertTag(s);
            }
            bomped = true;
            notify()
        }

        function insertTag(value) {
            input.parentNode.insertBefore(makeTagEle(sanitizeTag(value)), input);            
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
