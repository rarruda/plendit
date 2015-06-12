window.controllers = window.controllers || {};


window.controllers.tageditor = {
    dependencies: ["$element", "tagbox"],
    callable: function(ele, tagBox) {

        init();


        function init() {
            tagBox(ele, {
                tagClassName: "tag-editor__tag",
                inputClassName: "tag-editor__input",
                onChange: onChange,
                tags: getCurrentTags()
            });
        }

        function getCurrentTags() {
            var e = ele.querySelector("input[type=hidden]");
            return e ? e.value.split(", ") : [];
        }

        function setCurrentTags(tags) {
            var e = ele.querySelector("input[type=hidden]");
            if (e) {
                e.value = tags.join(", ");
            }
        }

        function onChange(tags) {
            setCurrentTags(tags);
        }

    }
}