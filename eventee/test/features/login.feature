Feature: Login
  The login screen should take me to the select a conference page if my credentials are correct.

  Scenario: Login with correct credentials
    Given I fill the 'email' field with 'attendee@email.com'
    And I fill the 'password' field with 'password'
    When I tap the 'Login as Attendee' button
    Then I expect the text 'Select Conference' to be present within 10 seconds