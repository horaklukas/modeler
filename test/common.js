var chai, sinonChai;

chai = require('chai');
chai.should();
global.mockery = require('mockery');
global.expect = chai.expect;
global.sinon = require('sinon');
global.request = require('supertest');
sinonChai = require('sinon-chai');
chai.use(sinonChai);