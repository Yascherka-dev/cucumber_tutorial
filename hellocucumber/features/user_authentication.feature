Feature: User Authentication
  As a security system
  I want to authenticate users
  So that only authorized users can access the system

  Background:
    Given the system has the following users:
      | username | password |
      | admin    | admin123 |
      | user1    | pass123  |
      | testuser | testpass |

  @smoke @login
  Scenario: Successful login with valid credentials
    Given I am on the login page
    When I enter username "admin" and password "admin123"
    And I click the login button
    Then I should be logged in successfully
    And I should see the message "Welcome, admin!"

  @login
  Scenario: Failed login with incorrect password
    Given I am on the login page
    When I enter username "admin" and password "wrongpass"
    And I click the login button
    Then I should see an error message "Invalid credentials"
    And I should not be logged in

  @login
  Scenario: Failed login with non-existent username
    Given I am on the login page
    When I enter username "unknown" and password "anypass"
    And I click the login button
    Then I should see an error message "User not found"
    And I should not be logged in

  @validation
  Scenario: Login validation - empty username
    Given I am on the login page
    When I enter empty username and password "pass"
    And I click the login button
    Then I should see an error message "Username is required" about login

  @validation
  Scenario: Login validation - empty password
    Given I am on the login page
    When I enter username "user" and empty password
    And I click the login button
    Then I should see an error message "Password is required" about login

  @validation
  Scenario: Login validation - both empty
    Given I am on the login page
    When I enter empty username and empty password
    And I click the login button
    Then I should see an error message "Username and password are required" about login

  @security
  Scenario: Account locked after 3 failed attempts
    Given the system has the following users:
      | username | password |
      | testuser | correctpass |
    And I am on the login page
    When I try to login with incorrect credentials 3 times
    Then my account should be locked
    And I should see the message "Account locked. Please contact administrator."

