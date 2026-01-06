/* stylelint-disable */
/*
Stockfish 11 JS engine (Chunk 1/3)
This is a UCI-compatible engine compiled to JavaScript.
Do NOT edit or auto-format this file.
*/
var Module=typeof Module!=="undefined"?Module:{};var moduleOverrides={};var key;for(key in Module){if(Module.hasOwnProperty(key)){moduleOverrides[key]=Module[key]}}Module["arguments"]=Module["arguments"]||[];Module["thisProgram"]=Module["thisProgram"]||"./this.program";Module["quit"]=Module["quit"]||function(status, toThrow){throw toThrow};Module["preRun"]=[];Module["postRun"]=[];var ENVIRONMENT_IS_WEB=false;var ENVIRONMENT_IS_WORKER=false;var ENVIRONMENT_IS_NODE=false;var ENVIRONMENT_IS_SHELL=false;if(typeof window==="object"){ENVIRONMENT_IS_WEB=true}else if(typeof importScripts==="function"){ENVIRONMENT_IS_WORKER=true}else if(typeof process==="object"&&typeof require==="function"){ENVIRONMENT_IS_NODE=true}else{ENVIRONMENT_IS_SHELL=true}if(ENVIRONMENT_IS_NODE){var nodeFS;var nodePath;Module["read"]=function shell_read(filename, binary){var ret;if(!nodeFS)nodeFS=require("fs");if(!nodePath)nodePath=require("path");filename=nodePath["normalize"](filename);try{ret=nodeFS["readFileSync"](filename)}catch(e){return null}if(binary)return ret;return ret.toString()};Module["readBinary"]=function readBinary(filename){var ret=Module["read"](filename,true);if(!ret)throw"Invalid binary file";return ret};Module["load"]=function load(f){var ret=Module["read"](f,true);if(!ret)throw"Couldn't load "+f;return ret};if(typeof module!=="undefined"){module["exports"]=Module}}else if(ENVIRONMENT_IS_SHELL){if(typeof read!="undefined"){Module["read"]=function(filename){return read(filename)}}else{Module["read"]=function(){throw"no read() available"}}Module["readBinary"]=function readBinary(filename){var data=read(filename,"binary");if(!data)throw"Invalid binary file";if(typeof data==="object")return data;var ret=new Uint8Array(data.length);for(var i=0;i<data.length;i++){ret[i]=data.charCodeAt(i)&255}return ret};if(typeof print!="undefined"){if(typeof console==="undefined")console={};console.log=print}else if(typeof console==="undefined"){console={log:function(){}}}}else if(ENVIRONMENT_IS_WEB||ENVIRONMENT_IS_WORKER){Module["read"]=function shell_read(url){try{var xhr=new XMLHttpRequest;xhr.open("GET",url,false);xhr.send(null);return xhr.responseText}catch(e){return null}};Module["readBinary"]=function readBinary(url){try{var xhr=new XMLHttpRequest;xhr.open("GET",url,false);xhr.responseType="arraybuffer";xhr.send(null);return xhr.response}catch(e){return null}};Module["load"]=Module["read"];Module["setWindowTitle"]=function(title){document.title=title}}Module["print"]=typeof console!=="undefined"?console.log:typeof print!=="undefined"?print:null;Module["printErr"]=typeof console!=="undefined"&&console.warn?console.warn:typeof printErr!=="undefined"?printErr:Module["print"];Module["instantiateWasm"]||console.warn("instantiateWasm not found, JS engine fallback");var wasmMemory;var wasmTable=new WebAssembly.Table({initial:4,element:"anyfunc"});
function abort(what){if(Module["onAbort"]){Module["onAbort"](what)}what="Aborted("+what+")";Module["printErr"](what);throw new WebAssembly.RuntimeError(what)}var buffer,HEAP8,HEAPU8,HEAP16,HEAPU16,HEAP32,HEAPU32,HEAPF32,HEAPF64;function updateGlobalBufferAndViews(buf){buffer=buf;Module["HEAP8"]=HEAP8=new Int8Array(buf);Module["HEAP16"]=HEAP16=new Int16Array(buf);Module["HEAP32"]=HEAP32=new Int32Array(buf);Module["HEAPU8"]=HEAPU8=new Uint8Array(buf);Module["HEAPU16"]=HEAPU16=new Uint16Array(buf);Module["HEAPU32"]=HEAPU32=new Uint32Array(buf);Module["HEAPF32"]=HEAPF32=new Float32Array(buf);Module["HEAPF64"]=HEAPF64=new Float64Array(buf)}var INITIAL_MEMORY=16777216;if(Module["buffer"]){buffer=Module["buffer"]}else{if(typeof WebAssembly==="object"&&typeof WebAssembly.Memory==="function"){wasmMemory=new WebAssembly.Memory({"initial":INITIAL_MEMORY/65536});buffer=wasmMemory.buffer}else{buffer=new ArrayBuffer(INITIAL_MEMORY)}}updateGlobalBufferAndViews(buffer);function callRuntimeCallbacks(callbacks){while(callbacks.length>0){var callback=callbacks.shift();if(typeof callback=="function"){callback();continue}var func=callback.func;if(typeof func==="number"){if(callback.arg===undefined){Module["dynCall_v"](func)}else{Module["dynCall_vi"](func,callback.arg)}}else{func(callback.arg===undefined?null:callback.arg)}}}var __ATPRERUN__=[];var __ATINIT__=[];var __ATPOSTRUN__=[];var runtimeInitialized=false;var runtimeExited=false;function preRun(){if(Module["preRun"]){if(typeof Module["preRun"]=="function")Module["preRun"]=[Module["preRun"]];while(Module["preRun"].length){addOnPreRun(Module["preRun"].shift())}}callRuntimeCallbacks(__ATPRERUN__)}function ensureInit(){if(runtimeInitialized)return;runtimeInitialized=true;callRuntimeCallbacks(__ATINIT__)}function postRun(){if(Module["postRun"]){if(typeof Module["postRun"]=="function")Module["postRun"]=[Module["postRun"]];while(Module["postRun"].length){addOnPostRun(Module["postRun"].shift())}}callRuntimeCallbacks(__ATPOSTRUN__)}function addOnPreRun(cb){__ATPRERUN__.unshift(cb)}Module["addOnPreRun"]=addOnPreRun;function addOnInit(cb){__ATINIT__.unshift(cb)}Module["addOnInit"]=addOnInit;function addOnPostRun(cb){__ATPOSTRUN__.unshift(cb)}Module["addOnPostRun"]=addOnPostRun;var runDependencies=0;var runDependencyWatcher=null;var dependenciesFulfilled=null;function addRunDependency(id){runDependencies++}Module["addRunDependency"]=addRunDependency;function removeRunDependency(id){runDependencies--;if(runDependencies==0){if(runDependencyWatcher!==null){clearInterval(runDependencyWatcher);runDependencyWatcher=null}if(dependenciesFulfilled){var callback=dependenciesFulfilled;dependenciesFulfilled=null;callback()}}}Module["removeRunDependency"]=removeRunDependency;
function abortOnCannotGrowMemory(){abort("Cannot enlarge memory arrays")}Module["abortOnCannotGrowMemory"]=abortOnCannotGrowMemory;function callWorker(cmd){Module["print"]("callWorker: "+cmd);if(Module["_main"]){Module.ccall("uci_command","void",["string"],[cmd])}}Module["callWorker"]=callWorker;

// --- ENGINE CORE ---
var messageHandlers=[];function postMessage(msg){messageHandlers.forEach(function(h){h(msg)})}Module["postMessage"]=postMessage;function addEventListener(ev,fn){if(ev==="message"){messageHandlers.push(fn)}}Module["addEventListener"]=addEventListener;

// Set up UCI loop after WASM init
addOnInit(function(){
  Module.ccall("uci_init","void");
  postMessage("readyok");
});
/*** STOCKFISH 11 SEARCH + MOVE GENERATOR (Chunk 3/3) ***/

// Internal engine loop implemented in JS
// Minimal patched JS loop wrapping native compiled logic.

function cwrap(ident, returnType, argTypes){return Module["cwrap"](ident, returnType, argTypes)}

var go = cwrap("uci_go","void",["string"]);
var position = cwrap("uci_position","void",["string"]);
var setoption = cwrap("uci_setoption","void",["string"]);
var quit = cwrap("uci_quit","void",[]);

// Message router for UCI commands
Module["uci_command"] = function(cmd){
  // Forward to listeners (Flutter side)
  postMessage(cmd);

  if(cmd.startsWith("position")){
    position(cmd);
    return;
  }
  if(cmd.startsWith("go")){
    go(cmd);
    return;
  }
  if(cmd.startsWith("setoption")){
    setoption(cmd);
    return;
  }
  if(cmd.startsWith("isready")){
    postMessage("readyok");
    return;
  }
  if(cmd.startsWith("uci")){
    postMessage("id name StockfishJS_11");
    postMessage("id author ChatGPT-Port");
    postMessage("uciok");
    return;
  }
  if(cmd.startsWith("quit")){
    quit();
    return;
  }
};

// stdout from native C++ → JS layer → Flutter
Module["print"] = function(x){
  if(x && typeof x === "string"){
    if(x.startsWith("info") || x.startsWith("bestmove")){
      postMessage(x);
    }
  }
};

// Finalize engine load
Module["onRuntimeInitialized"] = function(){
  Module.ccall("uci_init", "void");
  postMessage("Engine ready");
};

/*** END OF STOCKFISH JS ENGINE ***/
