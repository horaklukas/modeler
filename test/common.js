var chai, sinonChai;

chai = require('chai');
chai.should();
global.mockery = require('mockery');
global.expect = chai.expect;
global.sinon = require('sinon');
global.request = require('supertest');
global.TestUtils = require('react-test-utils');
sinonChai = require('sinon-chai');
chai.use(sinonChai);