var chai, sinonChai;

chai = require('chai');
chai.should();
global.mockery = require('mockery');
global.expect = chai.expect;
global.sinon = require('sinon');
sinonChai = require('sinon-chai');
chai.use(sinonChai);