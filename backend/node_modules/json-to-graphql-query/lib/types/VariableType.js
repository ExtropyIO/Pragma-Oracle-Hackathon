"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.VariableType = void 0;
var VariableType = (function () {
    function VariableType(value) {
        this.value = value;
    }
    VariableType.prototype.toJSON = function () {
        return "$".concat(this.value);
    };
    return VariableType;
}());
exports.VariableType = VariableType;
//# sourceMappingURL=VariableType.js.map