var chai, sinonChai;

chai = require('chai');
chai.should();
global.expect = chai.expect;
global.sinon = require('sinon');
sinonChai = require('sinon-chai');
//$ = jQuery = require('jquery');

chai.use(sinonChai);