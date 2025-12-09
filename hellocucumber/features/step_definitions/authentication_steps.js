const assert = require('assert');
const { Given, When, Then } = require('@cucumber/cucumber');

// Simple authentication system
class AuthenticationSystem {
  constructor() {
    this.users = {};
    this.currentUser = null;
    this.loginAttempts = {};
    this.isLoggedIn = false;
    this.errorMessage = null;
  }

  addUser(username, password) {
    this.users[username] = password;
  }

  login(username, password) {
    // Check for empty fields - check both empty first
    if ((!username || username === '') && (!password || password === '')) {
      this.errorMessage = 'Username and password are required';
      return false;
    }
    if (!username || username === '') {
      this.errorMessage = 'Username is required';
      return false;
    }
    if (!password || password === '') {
      this.errorMessage = 'Password is required';
      return false;
    }

    // Check if user exists
    if (!this.users[username]) {
      this.errorMessage = 'User not found';
      return false;
    }

    // Check password
    if (this.users[username] !== password) {
      this.errorMessage = 'Invalid credentials';
      // Track login attempts
      this.loginAttempts[username] = (this.loginAttempts[username] || 0) + 1;
      return false;
    }

    // Successful login
    this.currentUser = username;
    this.isLoggedIn = true;
    this.errorMessage = null;
    this.loginAttempts[username] = 0;
    return true;
  }

  getWelcomeMessage() {
    return `Welcome, ${this.currentUser}!`;
  }

  isAccountLocked(username) {
    return (this.loginAttempts[username] || 0) >= 3;
  }

  getLockedMessage() {
    return 'Account locked. Please contact administrator.';
  }
}

Given('the system has the following users:', function (dataTable) {
  this.authSystem = new AuthenticationSystem();
  const rows = dataTable.rows();
  for (const row of rows) {
    this.authSystem.addUser(row[0], row[1]);
  }
});

Given('I am on the login page', function () {
  this.authSystem = this.authSystem || new AuthenticationSystem();
  this.isOnLoginPage = true;
});

When('I enter username {string} and password {string}', function (username, password) {
  this.enteredUsername = username;
  this.enteredPassword = password;
});

When('I enter empty username and password {string}', function (password) {
  this.enteredUsername = '';
  this.enteredPassword = password;
});

When('I enter username {string} and empty password', function (username) {
  this.enteredUsername = username;
  this.enteredPassword = '';
});

When('I enter empty username and empty password', function () {
  this.enteredUsername = '';
  this.enteredPassword = '';
});

When('I click the login button', function () {
  this.authSystem.login(this.enteredUsername, this.enteredPassword);
});

Then('I should be logged in successfully', function () {
  assert.strictEqual(this.authSystem.isLoggedIn, true);
});

Then('I should see the message {string}', function (expectedMessage) {
  if (this.authSystem.isLoggedIn) {
    assert.strictEqual(this.authSystem.getWelcomeMessage(), expectedMessage);
  } else if (this.authSystem.isAccountLocked('testuser')) {
    assert.strictEqual(this.authSystem.getLockedMessage(), expectedMessage);
  } else {
    assert.strictEqual(this.authSystem.errorMessage, expectedMessage);
  }
});

Then('I should not be logged in', function () {
  assert.strictEqual(this.authSystem.isLoggedIn, false);
});

Then('I should see an error message {string}', function (expectedError) {
  assert.strictEqual(this.authSystem.errorMessage, expectedError);
});

Then('I should see an error message {string} about login', function (expectedError) {
  assert.strictEqual(this.authSystem.errorMessage, expectedError);
});

When('I try to login with incorrect credentials {int} times', function (times) {
  this.authSystem = this.authSystem || new AuthenticationSystem();
  this.authSystem.addUser('testuser', 'correctpass');
  
  for (let i = 0; i < times; i++) {
    this.authSystem.login('testuser', 'wrongpass');
  }
});

Then('my account should be locked', function () {
  assert.strictEqual(this.authSystem.isAccountLocked('testuser'), true);
});

