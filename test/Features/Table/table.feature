Feature: Table

  Scenario Outline: Table
    Given I have the following table
      | id | desc   |
      | 42 | number |
      | 11 | text   |
     When I choose <id>
     Then I should get '<desc>'

     Examples:
       | id | desc |
       | 42 | number |
       | 11 | text |
