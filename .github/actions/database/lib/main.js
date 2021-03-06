"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (Object.hasOwnProperty.call(mod, k)) result[k] = mod[k];
    result["default"] = mod;
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
const core = __importStar(require("@actions/core"));
const exec = __importStar(require("@actions/exec"));
function run() {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const options = {
                cwd: './apps/s12y',
            };
            core.exportVariable('MIX_ENV', 'test');
            core.exportVariable('POSTGRES_HOST', 'postgres');
            core.exportVariable('POSTGRES_PORT', '5432');
            yield exec.exec('mix', ['local.rebar', '--force'], options);
            yield exec.exec('mix', ['local.hex', '--force'], options);
            yield exec.exec('mix', ['deps.get'], options);
            yield exec.exec('mix', ['ecto.setup'], options);
        }
        catch (error) {
            core.setFailed(error.message);
        }
    });
}
run();
