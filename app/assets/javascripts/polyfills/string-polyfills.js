if (!String.prototype.startsWith) {
    String.prototype.startsWith = function(s) {
        return this.indexOf(s) == 0;
    }
}

if (!String.prototype.endsWith) {
    String.prototype.endsWith = function(s) {
        return this.lastIndexOf(s) == this.length - s.length;
    }
}