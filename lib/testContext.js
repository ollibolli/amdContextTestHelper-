/*node*/
var contextify = require('contextify');
var fs = require('fs');
var jsdom = require('jsdom');



exports.createSandbox = function(depMock, scripts, html, config, callback){
	var sandbox = {};
	
	if (arguments.length < 2){
		throw new Error('not enouthg parameters');
	}else if (arguments.length == 2){
		callback=scripts;
		contextifySandbox();
		callback(sandbox);
	}else if (arguments.length == 3){
		callback = html;
		html = '<html><head><title>Empty</head><body></body></html>';
		jsdom.env(html, scripts, jsdomSandboxEnvCb);	
	}else if (arguments.length == 4){
		callback = config;
		jsdom.env(html, scripts, jsdomSandboxEnvCb);	
	}else {
		jsdom.env(html, scripts, config, jsdomSandboxEnvCb);	
	}

	function jsdomSandboxEnvCb(err, window){
		if (err) {
			console.log(err);
			throw err;
		}
		sandbox = window;
		sandbox.window=window;
		contextifySandbox();
		callback(sandbox);
	}
	function contextifySandbox(){
		sandbox.console = global.console;
		sandbox.define = exports._defineRequireMock(depMock);
		sandbox.require = exports._defineRequireMock(depMock)
		contextify(sandbox);
	}
}
/**
 * @param {object} contextifyed object (sandbox)
 * @Param {string} path to js module file to invoke in sandbox
 * @Param {function} callback(<module object>)
 */
exports.snadboxRequire = function loadModuleUnderTest(sandbox, modulePath, callback) {
  	fs.readFile(modulePath, 'utf8', function(err, data) {
    	if(err)
      		throw err;
      	sandbox._testObject = 'gluhvhv';
	    sandbox.run(data);
	    var iId = setInterval(function(){
	    	if (sandbox._testObject !== 'gluhvhv') {
	    		clearInterval(iId);
	    		callback(sandbox._testObject);
	    	}
	    },1);
	});
}

exports._defineRequireMock = function defineRequireMock(mockMap){
  
  function isArray(it) {
        var ostring = Object.prototype.toString;
        return ostring.call(it) === '[object Array]';
    }
  
  return function define(name, deps, callback) {
      if (typeof name !== 'string') {
          //Adjust args appropriately
          callback = deps;
          deps = name;
          name = null;
      }
  
      //This module may not have dependencies
      if (!isArray(deps)) {
          callback = deps;
          deps = [];
      }
    
    if (isArray(deps)){
      var args = []
      for (var i = 0 ;deps.length > i; i++){
        args.push(mockMap[deps[i]]);        
      }
      var obj = callback.apply(this,args);
      this._testObject = obj;
      return obj;   
    } else {console.log ('Deps not a array error')}
  } 
  
}

/* TESTS  
mockDep = {'o' : {
    member : 'member'
  }
}

var def = defineRequireMock(mockDep);

def(['o'],function(o){
  console.log(o);
  assert.equal(o.member,'member');
}); 

try {
  def(['h'],function(h){
    console.log(h);
  }); 
  
  def('o',function(o){
    console.log(o);
  });
   
} catch(e){
  console.log(e)
};

*/