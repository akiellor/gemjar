README [![Build Status](https://api.travis-ci.org/akiellor/gemjar.png)](http://travis-ci.org/akiellor/gemjar)
======

So what does it do?
-------------------

It's an Ivy-compatible proxy for RubyGems, which translates gems into JRuby-compatible JARs.

This tool is for people who:

  * Are working with the Java tool chain: good ol' `javac`, Maven, Ivy, Ant, Buildr and IDEs
  * Want to use some (J)Ruby
  * Want to use gems from RubyGems
  * Don't want to use multiple VMs (JVM and CRuby)
  * Don't want to hand-roll a GemJar everytime their ruby deps change
  * Don't want to use two dependencies management tools (Bundler + Ivy)

I'm hoping thats not just me...

Trying it out -- GemJars.org Hosted
-----------------------------------
### Gradle
1) Add to your `repositories`:
```
repositories {
    maven {
        url 'http://repository.gemjars.org/maven'
    }
}
```
2) Add to your `dependencies`:
```
dependencies {
    compile 'org.rubygems:rspec:2.11.0'
}
```
3) Perform a `gradle dependencies` and watch it resolve rspec and all its transitive dependencies

### Ivy
1) In your `ivysettings.xml`, set up the following resolver:

```xml
<ivysettings>
  ...
  <url name="gems">
    <ivy pattern="http://repository.gemjars.org/ivys/[organization]/ivy-[module]-[revision].xml" />
    <artifact pattern="http://repository.gemjars.org/jars/[organization]/[module]-[revision].jar" />
  </url>
  ...
  <chain name="default">
    ...
    <resolver ref="gems" />
  </chain>
</ivysettings>
```

2) In your `ivy.xml`, add a dependency from `org.rubygems`.

```xml
<ivy-module version="2.0">
  <dependency org="org.rubygems" name="cucumber" rev="1.0.0" />
</ivy-module>
```

3) Perform an `ivy resolve` and watch Ivy resolve cucumber and all its transitive dependencies.

Trying it out -- DIY
--------------------
1) Clone the repo:
  
  ```
  $ git clone git://github.com/akiellor/gemjar.git
  ```

2) Get Gradle
  ```
  brew install gradle
  ```
  
  OR
  
  Get it from gradle.org.
  
3) RUN IT:
  
  ```
  $ gradle run 
  ```

4) Hit some urls:
  
  ```
  $ curl -i http://localhost:8080/jars/org.rubygems/cucumber-1.0.0.jar
  $ curl -i http://localhost:8080/jars/org.rubygems/cucumber-1.0.0.jar.md5
  $ curl -i http://localhost:8080/jars/org.rubygems/cucumber-1.0.0.jar.sha1
  $ curl -i http://localhost:8080/ivys/org.rubygems/ivy-cucumber-1.0.0.xml
  $ curl -i http://localhost:8080/ivys/org.rubygems/ivy-cucumber-1.0.0.xml.md5
  $ curl -i http://localhost:8080/ivys/org.rubygems/ivy-cucumber-1.0.0.xml.sha1
  ```

Where's it at?
-------------
**THIS IS A PROTOTYPE**

### DONE-ISH ###
* Construction of jruby compatible gemjars. 
* Construction of ivy modules based on the gemspec. 
* MD5 and SHA1 of all constructed artifacts. 
* Can be built as a war.
* Maven `pom.xml` generation.

### HOW CAN YOU HELP ###
* Try it out.
* Give me feed back.

License
-------
[Apache 2.0](http://www.opensource.org/licenses/Apache-2.0)
