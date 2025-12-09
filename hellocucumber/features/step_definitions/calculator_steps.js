const assert = require('assert');
const { Given, When, Then } = require('@cucumber/cucumber');

// Simple calculator implementation
class Calculator {
  constructor() {
    this.result = 0;
  }

  add(a, b) {
    this.result = a + b;
    return this.result;
  }

  subtract(a, b) {
    this.result = a - b;
    return this.result;
  }

  multiply(a, b) {
    this.result = a * b;
    return this.result;
  }

  divide(dividend, divisor) {
    if (divisor === 0) {
      throw new Error('Cannot divide by zero');
    }
    this.result = dividend / divisor;
    return this.result;
  }
}

Given('I have a calculator', function () {
  this.calculator = new Calculator();
});

When('I add {int} and {int}', function (a, b) {
  this.calculator.add(a, b);
});

When('I subtract {int} from {int}', function (b, a) {
  this.calculator.subtract(a, b);
});

When('I multiply {int} by {int}', function (a, b) {
  this.calculator.multiply(a, b);
});

When('I divide {int} by {int}', function (dividend, divisor) {
  try {
    this.calculator.divide(dividend, divisor);
    this.error = null;
  } catch (error) {
    this.error = error.message;
  }
});

Then('the result should be {float}', function (expected) {
  assert.strictEqual(this.calculator.result, expected);
});

Then('I should get an error message {string}', function (expectedError) {
  assert.strictEqual(this.error, expectedError);
});

