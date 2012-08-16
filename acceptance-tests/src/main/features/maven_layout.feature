Feature: GemJar - MavenLayout

  @wip
  Scenario: Resolves an ivy dependency
    When I hit the URL "/maven/org/rubygems/rspec/2.6.0/rspec-2.6.0.pom"
    Then the response should be a valid maven pom xml

  @wip
  Scenario: Resolves a jar dependency
    When I hit the URL "/maven/org/rubygems/rspec/2.6.0/rspec-2.6.0.jar"
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

  @wip
  Scenario: Gets a poms sha1
    When I hit the URL "/maven/org/rubygems/rspec/2.6.0/rspec-2.6.0.pom.sha1"
    Then the response should contain the sha1 of "/maven/org/rubygems/rspec/2.6.0/rspec-2.6.0.pom"

  @wip
  Scenario: Gets a poms md5
    When I hit the URL "/maven/org/rubygems/rspec/2.6.0/rspec-2.6.0.pom.md5"
    Then the response should contain the md5 of "/maven/org/rubygems/rspec/2.6.0/rspec-2.6.0.pom"

  @wip
  Scenario: Gets a jar dependencies' sha1
    When I hit the URL "/maven/org/rubygems/rspec/2.6.0/rspec-2.6.0.jar.sha1"
    Then the response should contain the sha1 of "/maven/org/rubygems/rspec/2.6.0/rspec-2.6.0.jar"

  @wip
  Scenario: Gets a jar dependencies' md5
    When I hit the URL "/maven/org/rubygems/rspec/2.6.0/rspec-2.6.0.jar.md5"
    Then the response should contain the md5 of "/maven/org/rubygems/rspec/2.6.0/rspec-2.6.0.jar"
