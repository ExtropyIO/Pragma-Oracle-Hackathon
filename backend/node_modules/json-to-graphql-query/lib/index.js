"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !Object.prototype.hasOwnProperty.call(exports, p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.VariableType = exports.EnumType = void 0;
__exportStar(require("./jsonToGraphQLQuery"), exports);
var EnumType_1 = require("./types/EnumType");
Object.defineProperty(exports, "EnumType", { enumerable: true, get: function () { return EnumType_1.EnumType; } });
var VariableType_1 = require("./types/VariableType");
Object.defineProperty(exports, "VariableType", { enumerable: true, get: function () { return VariableType_1.VariableType; } });
//# sourceMappingURL=index.js.map