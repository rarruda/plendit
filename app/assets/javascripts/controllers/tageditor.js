window.controllers = window.controllers || {};


window.controllers.tageditor = {
    dependencies: ["$element", "tagbox"],
    callable: function(ele, tagBox) {
        tagBox(ele, {
            tagClassName: "tag-editor__tag",
            inputClassName: "tag-editor__input",
        });
    }
}