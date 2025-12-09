Feature: Calculator
  As a user
  I want to perform basic calculations
  So that I can solve mathematical problems

  Background:
    Given I have a calculator

  Scenario: Addition of two positive numbers
    When I add 5 and 3
    Then the result should be 8

  Scenario: Subtraction of two numbers
    When I subtract 3 from 10
    Then the result should be 7

  Scenario Outline: Multiplication
    When I multiply <a> by <b>
    Then the result should be <result>

    Examples:
      | a | b | result |
      | 2 | 3 | 6      |
      | 5 | 4 | 20     |
      | 0 | 5 | 0      |
      | 10 | 10 | 100  |

  Scenario Outline: Division
    When I divide <dividend> by <divisor>
    Then the result should be <result>

    Examples:
      | dividend | divisor | result |
      | 10       | 2       | 5      |
      | 15       | 3       | 5      |
      | 7        | 2       | 3.5   |

  @negative
  Scenario: Division by zero should fail
    When I divide 10 by 0
    Then I should get an error message "Cannot divide by zero"

