Feature: Run the rules family

  Scenario: Run one rules family
    Given Rules family file: "./ttl/RulesToGraphviz.ttl"
    And Rules family name: ""
    And Fakts file: ""
    When The rules engine is run
    Then The output should have "dd"