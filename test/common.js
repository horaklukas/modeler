var chai, expect, sinonChai;

chai = require('chai');
chai.should();
expect = chai.expect;
sinonChai = require("sinon-chai");

chai.use(sinonChai);