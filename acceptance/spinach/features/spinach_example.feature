Feature: Example Spinach feature
  As a conscientious developer who writes features
  I want to be able to see my features passing on the CI Server
  So that I can bask in the glow of a green bar

  Scenario: Conscientious developer
    Given that I am a conscientious developer
    And I write cucumber features
    Then I should see a green bar

  Scenario: Lazy hacker
    Given that I am a lazy hacker
    And I don't bother writing cucumber features
    Then I should be fired

  Scenario: Bad coder
    Given that I can't code for peanuts
    And I write step definitions that throw exceptions
    Then I shouldn't be allowed out in public

  Scenario: Missing steps
    Given that I am a lazy hacker
    And I don't implement steps before I commit
    Then I should be fired
