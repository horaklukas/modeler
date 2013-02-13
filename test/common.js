var chai, sinonChai;

chai = require('chai');
chai.should();
global.expect = chai.expect;
global.sinon = require('sinon');
sinonChai = require('sinon-chai');
chai.use(sinonChai);

global.document = '<html />'
$ = jQuery = require('jquery');

// Directory containing source files
global.srcDir = process.cwd() + '/src'