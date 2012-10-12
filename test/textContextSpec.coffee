assert = require 'assert'
sinon = require 'sinon'
chai = require 'chai'
sinonChai = require 'sinon-chai'
fs = require 'fs'
contextify = require 'contextify'
chai.use(sinonChai) 
expect = chai.expect
should = chai.should()

mockDep = {
  'o' : { member : 'member' },
  'h' : { name : 'h' },
  'x' : { name : 'x' }
}

describe 'testContext', ->

  testContext = require '../lib/testContext'
            
  describe 'have a createSandbox function', ->
        
    describe 'createSandbox(mockobjs,callback) return a object', ->  
      testContext.createSandbox mockDep, (sandbox) -> 
        it 'that should have a run method equal to a contextifyd object run method', -> 
          assert.equal sandbox.run.toString(), (contextify({})).run.toString()
        
        it 'that should have a require method', ->
          assert.ok sandbox.require
          describe 'the require method', ->          
            it 'should take a array of dependency modules id and pas the mock objects as paremeter in a callback functoion', ->
              callback = sinon.spy()
              sandbox.require(['o','h'], callback)
              callback.should.have.been.calledWith(mockDep['o'],mockDep['h'])               
        
        it 'should have a define method', ->
          assert.ok sandbox.define
          
          describe 'the define method', ->          
            
            it 'should take a array of dependency modules id and pas the mock objects as paremeter in a callback functoion', ->
              callback = sinon.spy()
              sandbox.require(['o','h'], callback)
              callback.should.have.been.calledWith(mockDep['o'],mockDep['h'])
        it 'sandbox should not have a window object or document obj ', (done)->
            expect(sandbox.window).to.not.be.ok
            expect(sandbox.document).to.not.be.ok
            done()

    
    describe 'createSandbox(mockObjects , [scripts] , callback)', ->
        it 'should setup a require method on sandbox',  (done) ->
          testContext.createSandbox mockDep, ['../testRecources/PreRequireNonAMD.js'], (sandbox) ->
            sandbox.should.have.property('require').to.be.a.be('function');
            done()
 
        it 'should setup a define method on sandbox',(done) ->
          testContext.createSandbox mockDep, ['../testRecources/PreRequireNonAMD.js'], (sandbox) ->
            sandbox.should.have.property('define').to.be.a('function');
            done()
        
        it 'should setup a run method on sandbox', (done)->
          testContext.createSandbox mockDep, ['../testRecources/PreRequireNonAMD.js'], (sandbox) ->
            expect(sandbox).to.have.property('run').to.be.a('function');
            done()

        it 'should setup a new global function on sandbox', (done)->
          testContext.createSandbox mockDep, ['../testRecources/PreRequireNonAMD.js'], (sandbox) ->
            expect(sandbox).to.have.property('globalFunk').to.be.a('function');
            done()
        
        it 'should setup a new global member on sandbox', (done)->
          testContext.createSandbox mockDep, ['../testRecources/PreRequireNonAMD.js'], (sandbox) ->
            expect(sandbox).to.have.property('globalVar').to.be.a('string');
            done()
                 
    describe 'createSandbox(mockObjects , [scripts], html, callback)', ->
        it 'should load a document and scripts',  (done) ->
          testContext.createSandbox mockDep, ['../testRecources/PreRequireNonAMD.js'], '<html><head><title>Empty</head><body><p>oo</p></body></html>(sandbox)', (sandbox) ->
            expect(sandbox.document.getElementsByTagName('p')).to.have.length(1)
            done()
  
  describe 'sould have a snadboxRequire method ', ->
    
    it 'that when called should call the callback with the model object' , (done)->
      testContext.createSandbox mockDep , (sandbox) ->
        testContext.snadboxRequire sandbox ,'testRecources/AMDTestFile.js' , (file) ->
           expect(file['o']).to.be.equal(mockDep['o'])
           done()
    
    it 'that when module that make global variables sets them on sandbox obj' , (done)->
      testContext.createSandbox mockDep, (sandbox) ->
        testContext.snadboxRequire sandbox ,'testRecources/AMDTestFile2.js' , (file) ->
           expect(sandbox.oo).to.be.equal(mockDep['o'])
           done()

