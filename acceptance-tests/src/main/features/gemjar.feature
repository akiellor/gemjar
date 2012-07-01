Feature: GemJar

  Scenario: Resolves an ivy dependency
    When I hit the URL "/ivys/org.rubygems/ivy-rspec-2.6.0.xml"
    Then the response should be a valid ivy xml
