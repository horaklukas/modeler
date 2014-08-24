var chai, sinonChai;

chai = require('chai');
global.request = require('supertest');
global.mockery = require('mockery');
global.sinon = require('sinon');
global.expect = chai.expect;

chai.should();
sinonChai = require('sinon-chai');
chai.use(sinonChai);