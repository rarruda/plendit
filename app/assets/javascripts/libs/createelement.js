/**
 * Create an element.
 *
 * Examples:
 *
 *   createElement("div") returns a div element without attributes or content.
 *   createElement("div", {title: 1}) returns an element with a title attribute.
 *   createElement("div", null, "test") sets the content of the element to "test".
 *
 * There's a shortcut for setting classes:
 *
 *   createElement("div.class1.class2")
 *
 * The content of the element can be an array and it takes several arguments:
 *
 *   createElement("div", null, group.map(item => render(item)))
 *   createElement("div", null, "1", "2", "3")
 *
 * If an attribute value is `null` or `false`, it won't be set. If it is `true`, it
 * will be set to the empty string. This makes it possible to set boolean attributes:
 *
 *   createElement("input", {disabled: isDisabled})
 *
 * If an attribute name starts with "on" and the value is a function, it will be set
 * as a (bubbling) event listener:
 *
 *   createElement("button", {onclick: handleClick}, "Click!")
 *
 * SVG and XLink namespaces are recognized when prefixing names with "svg:" or
 * "xlink:":
 *
 *   createElement("svg:svg", null,
 *     createElement("svg:use", {"xlink:href": "#id"})
 *   )
 *
 * @parameter {String} name The element type name, plus optional classes
 * @parameter {Object} attributes The element's attributes
 * @parameter {...any} content The element's content
 */
"use strict";

function createElement(name, attributes) {
    if (typeof name != "string") {
        throw TypeError("The name argument must be a string");
    }

    var babelHelpers = {
        toArray: function (arr) {
            return Array.isArray(arr) ? arr : Array.from(arr);
        },

        toConsumableArray: function (arr) {
            if (Array.isArray(arr)) {
                for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) arr2[i] = arr[i];
                return arr2;
            } else {
                return Array.from(arr);
            }
        },

        babelHelpers: function (arr, i) {
            if (Array.isArray(arr)) {
                return arr;
            } else {
                throw new TypeError("Invalid attempt to destructure non-iterable instance");
            }
        }
    };



    var defaultNamespace = document.documentElement.namespaceURI;

    // Handle class names shortcut

    var _name$split = name.split(".");

    var _name$split2 = babelHelpers.toArray(_name$split);

    var qName = _name$split2[0];

    var classes = _name$split2.slice(1);

    var _getNamespaceParts = getNamespaceParts(qName);

    var _getNamespaceParts$namespace = _getNamespaceParts.namespace;
    var namespace = _getNamespaceParts$namespace === undefined ? defaultNamespace : _getNamespaceParts$namespace;
    var localName = _getNamespaceParts.localName;

    var ele = document.createElementNS(namespace, localName);

    if (classes.length) {
        var _ele$classList;

        (_ele$classList = ele.classList).add.apply(_ele$classList, babelHelpers.toConsumableArray(classes));
    }

    if (attributes != null) {
        if (typeof attributes != "object") {
            throw TypeError("The attributes argument must be an object");
        }

        if (attributes instanceof Node) {
            throw TypeError("The attributes argument cannot be a Node. Did you forget to pass attributes?");
        }

        // TODO: Object.entries()
        Object.keys(attributes).forEach(function (qName) {
            var value = attributes[qName];
            if (value !== null && value !== false) {
                if (value === true) {
                    value = ""; // Treat as boolean attribute
                }

                var _getNamespaceParts2 = getNamespaceParts(qName);

                var _namespace = _getNamespaceParts2.namespace;
                var _localName = _getNamespaceParts2.localName;

                if (_localName.startsWith("on") && typeof value == "function") {
                    ele.addEventListener(_localName.slice(2), value);
                    return;
                }

                // setAttributeNS() with the HTML namespace doesn't set IDL attributes
                if (_namespace) {
                    ele.setAttributeNS(_namespace, _localName, value);
                } else {
                    ele.setAttribute(_localName, value);
                }
            }
        });
    }

    for (var _len = arguments.length, content = Array(_len > 2 ? _len - 2 : 0), _key = 2; _key < _len; _key++) {
        content[_key - 2] = arguments[_key];
    }

    content.filter(function (value) {
        return value !== null;
    }).reduce(function (prev, curr) {
        return prev.concat(curr);
    }, []) // flatten
        .forEach(function (value) {
            return ele.appendChild(toNode(value));
        });
    ele.normalize();

    function toNode(value) {
        switch (typeof value) {
            case "boolean":
            case "number":
            case "string":
                return document.createTextNode(value.toString());

            case "undefined":
                return document.createTextNode("undefined");

            default:
                if (value instanceof Node) {
                    return value;
                }
        }

        throw TypeError("Argument of type '" + typeof value + "' cannot be used as content.");
    }

    function getNamespace(prefix) {
        switch (prefix) {
            case "html":
                return "http://www.w3.org/1999/xhtml";
            case "svg":
                return "http://www.w3.org/2000/svg";
            case "xlink":
                return "http://www.w3.org/1999/xlink";
        }
    }

    function getNamespaceParts(qName) {
        if (qName.indexOf(":") != -1) {
            var _qName$split = qName.split(":");

            var _qName$split2 = babelHelpers.slicedToArray(_qName$split, 2);

            var prefix = _qName$split2[0];
            var _localName2 = _qName$split2[1];

            var _namespace2 = getNamespace(prefix);
            if (!_namespace2) {
                throw Error("No namespace found for prefix \"" + prefix + "\"");
            }
            return { namespace: _namespace2, localName: _localName2 };
        }

        return { localName: qName };
    }

    return ele;
}
