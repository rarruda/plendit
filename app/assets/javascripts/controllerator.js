(function(global) {
    "use strict";

    function Injectorator() {
        this.registry = {}; // things that can be instantiated
        this.instances = {}; // things that have been instantiated
    }

    Injectorator.prototype = {

        _makeErrorAndLog: function(msg) {
            var errorMessage = "[I] " + msg;
            console.error(errorMessage);
            return new Error(errorMessage);
        },

        _instantiateWithDependencies: function(name) {
            this._findDependencies(name).forEach(this._instantiate.bind(this));
        },

        _instantiate: function(name) {
            if (this.instances.hasOwnProperty(name) || !this.registry.hasOwnProperty(name)) {
                // OK to bail in this case, callling code will raise appropriate exception
                return false;
            }

            var entry = this.registry[name];
            var subject = entry.subject;

            if (typeof subject == 'function') {
                var args = this._getInstances(entry.dependencies);
                subject = subject.apply(null, args);
            }

            this.instances[name] = subject;
            return true;
        },

        _getInstances: function(names) {
            return names.map(function(e) {
                if (this.instances.hasOwnProperty(e)) {
                    return this.instances[e];
                }
                else {
                    throw this._makeErrorAndLog("Dependency not found: '" + e + "'");
                }
            }, this);
        },

        // does a topological search over the dependencies
        _findDependencies: function(name) {
            var ordered = [];
            var stackGuard = 50;
            var finder = (function(name) {
                if (stackGuard-- < 0) {
                    var errorMessage = "Found cyclic dependency while trying to resolve '" +
                        name + " <- " + this.registry[name].dependencies + "'";
                    throw this._makeErrorAndLog(errorMessage);
                }

                if (this.instances.hasOwnProperty(name) ||
                    !this.registry.hasOwnProperty(name)) {
                    return;
                }

                this.registry[name].dependencies.forEach(function(e) {
                    if (ordered.indexOf(e) == -1) { finder(e); }
                });

                ordered.push(name);
            }).bind(this);

            finder(name);

            return ordered;
        },

        _register: function(name, subject, deps) {
            this.registry[name] = {
                name: name,
                dependencies: deps || [],
                subject: subject
            };
        },

        registerFactory: function(name, subject, deps) {
            if (typeof subject != 'function') {
                throw this._makeErrorAndLog("Factory must be a function: '" + name + "'");
            }
            this._register(name, subject, deps);
        },

        registerInstance: function(name, subject) {
            this._register(name, subject);
            this.instances[name] = subject;
        },

        get: function(name) {
            if (!this.registry.hasOwnProperty(name)) {
                throw this._makeErrorAndLog("Injectable not found: '" + name + "'");
            }

            if (!this.instances.hasOwnProperty(name)) {
                this._instantiateWithDependencies(name);
            }

            return this.instances[name];
        }
    };

    function Controllerator() {
        this.controllers = {};
        this.controlledElements = [];
        this.injector = new Injectorator();
        this._eagerServices = [];
        this._pendingRun = false;
        this._running = false;

        this.registerInstance("$controllerator", this);

        this._defaultDependencies = [
            "$element", "$controllerator"
        ];
    }

    Controllerator.prototype = {

        _makeErrorAndLog: function(msg) {
            var errorMessage = "[C] " + msg;
            console.error(errorMessage);
            return new Error(errorMessage);
        },

        _getProperty: function(subject, name) {
            var parts = name.split(".");
            return parts.reduce(function(prev, cur) {
                return prev ? prev[cur] : null;
            }, subject);
        },

        _evaluateElement: function(ele) {
            var controlled = this.controlledElements;
            if (controlled.indexOf(ele) == -1) {
                var attr = ele.getAttribute("data-controller");
                attr = attr.trim().split(/\s+/);
                if (attr == "") {
                    this._makeErrorAndLog("Found empty controller attribute");
                }
                else {
                    var cnames = attr.filter(function(name) {
                        return name != "__proto__";
                    });
                    cnames.forEach(this._evaluateElementController.bind(this, ele));
                    controlled.push(ele);
                }
            }
        },

        _parseController: function(definition, defaultName) {
            definition = definition || {};

            var controller = {
                name: definition.name || defaultName,
                callable: definition.callable || definition,
                dependencies: definition.dependencies,
            };

            if (typeof controller.name != "string") {
                throw this._makeErrorAndLog("Tried registering controller without a name");
            }
            else if (typeof controller.callable != "function") {
                throw this._makeErrorAndLog("Controller definition contained no callable");
            }
            else {
                return controller;
            }
        },

        _evaluateElementController: function(ele, cname) {
            var controller = this.controllers[cname];
            if (controller) {
                try {
                    if (controller.dependencies && controller.callable.length != controller.dependencies.length) {
                        var msg = 'Warning: Arity mismatch in "' + controller.name + '". Controller takes' +
                            controller.callable.length + ' arguments, dependency provides ' +
                            controller.dependencies.length;
                        this._makeErrorAndLog(msg);
                    }
                    this._call(
                        controller.callable,
                        controller.dependencies || this._defaultDependencies,
                        {$element: ele}
                    );
                }
                catch (e) {
                    var msg = "Error initializing controller: " + cname + ", caused by: " + e.message;
                    this._makeErrorAndLog(msg);
                    e.message = msg;
                    console.error(e.stack);
                }
            }
            else {
                throw this._makeErrorAndLog("Could not find controller: " + cname);
            }
        },

        _call: function(fun, depNames, localDeps) {
            localDeps = localDeps || {};
            var deps = depNames.map(function(name) {
                return localDeps[name] || this.injector.get(name);
            }, this);
            fun.apply(null, deps);
        },

        scanControllers: function(namespace) {
            for (var name in namespace) {
                if (namespace.hasOwnProperty(name)) {
                    this.registerController(namespace[name], name);
                }
            }
        },

        scanServices: function(namespace) {
            for (var name in namespace) {
                if (namespace.hasOwnProperty(name)) {
                    this.registerService(namespace[name]);
                }
            }
        },

        registerInstance: function(name, instance) {
            this.injector.registerInstance(name, instance);
        },

        registerService: function(definition) {
            if (definition) {
                this.injector.registerFactory(definition.name, definition.callable, definition.dependencies || []);
                if (definition.eager) {
                    this._eagerServices.push(definition.name);
                }
            }
            else {
                this._makeErrorAndLog("Non-extant service attempted registered: " + definition);
            }
        },

        registerController: function(controller, defaultName) {
            var subject = this._parseController(controller, defaultName);
            this.controllers[subject.name] = subject;
        },

        run: function() {
            var maxLoops = 10;
            this._pendingRun = true;
            this._eagerServices.forEach(this.injector.get.bind(this.injector));
            this._eagerServices = [];

            // The _running/_pendingRun machinery is to make any recursive call to controller.run()
            // cause the controller to re-run when finished with its current evaluation, not perform it
            // recursivley. Recursive running doesn't hurt, but if the invoking call happened in a
            // promise, or somewhere else that does exception swallowing, there were no way to see
            // that errors occured during the recursive controllerator run.
            if (!this._running) {
                while (this._pendingRun) {
                    if (maxLoops-- < 0) {
                        throw this._makeErrorAndLog("Max controllerator.run() loops hit! Possible recursion error");
                    }

                    this._pendingRun = false;
                    this._running = true;
                    var eles = document.querySelectorAll("[data-controller]");
                    for (var n = 0, ele; ele = eles[n]; n++) {
                        this._evaluateElement(ele);
                    }
                    this._running = false;
                }
            }
        }
    };

    global.Injectorator = Injectorator;
    global.Controllerator = Controllerator;

})(window);