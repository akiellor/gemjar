Feature: GemJar

  Scenario: Resolves an ivy dependency
    When I hit the URL "/ivys/org.rubygems/ivy-rspec-2.6.0.xml"
    Then the response should be a valid ivy xml

  Scenario: Resolves a jar dependency
    When I hit the URL "/jars/org.rubygems/rspec-2.6.0.jar"
    Then the response should be a jar with directories:
    """
    doc/
    gems/
    gems/rspec-2.6.0/
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

  Scenario: Gets a ivy dependencies' sha1
    When I hit the URL "/ivys/org.rubygems/ivy-rspec-2.6.0.xml.sha1"
    Then the response should contain the sha1 of "/ivys/org.rubygems/ivy-rspec-2.6.0.xml"

  Scenario: Gets a ivy dependencies' md5
    When I hit the URL "/ivys/org.rubygems/ivy-rspec-2.6.0.xml.md5"
    Then the response should contain the md5 of "/ivys/org.rubygems/ivy-rspec-2.6.0.xml"

  Scenario: Gets a jar dependencies' sha1
    When I hit the URL "/jars/org.rubygems/rspec-2.6.0.jar.sha1"
    Then the response should contain the sha1 of "/jars/org.rubygems/rspec-2.6.0.jar"

  Scenario: Gets a jar dependencies' md5
    When I hit the URL "/jars/org.rubygems/rspec-2.6.0.jar.md5"
    Then the response should contain the md5 of "/jars/org.rubygems/rspec-2.6.0.jar"
