Feature: GemJar

  Scenario: Resolves an ivy dependency
    When I hit the URL "/ivys/org.rubygems/ivy-rspec-2.6.0.xml"
    Then the response should be a valid ivy xml

  Scenario: Resolves an jar dependency
    When I hit the URL "/jars/org.rubygems/rspec-2.6.0.jar"
    Then the response should be a jar with directories:
    """
    doc/
    gems/
    gems/rspec-2.6.0/
    gems/rspec-2.6.0/.document
    gems/rspec-2.6.0/.gitignore
    gems/rspec-2.6.0/Gemfile
    gems/rspec-2.6.0/lib/
    gems/rspec-2.6.0/lib/rspec/
    gems/rspec-2.6.0/lib/rspec/version.rb
    gems/rspec-2.6.0/lib/rspec.rb
    gems/rspec-2.6.0/License.txt
    gems/rspec-2.6.0/Rakefile
    gems/rspec-2.6.0/README.markdown
    gems/rspec-2.6.0/rspec.gemspec
    specifications/
    specifications/rspec-2.6.0.gemspec
    """
