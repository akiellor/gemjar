README
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

Trying it out.
--------------
1) Clone the repo:
  
  ```
  $ git clone git://github.com/akiellor/gemjar.git
  ```

2) Bundle:
  
  ```
  $ bundle 
  ```

3) Build the war:
  
  ```
  $ rake war
  ```

4) RUN IT!
  
  ```
  $ java -jar test_deps/winstone-0.9.10-hudson-24.jar --warfile out/app.war
  ```

5) Hit some urls:
  
  ```
  $ curl -i http://localhost:8080/jars/org.rubygems/cucumber-1.0.0.jar
  $ curl -i http://localhost:8080/jars/org.rubygems/cucumber-1.0.0.jar.md5
  $ curl -i http://localhost:8080/jars/org.rubygems/cucumber-1.0.0.jar.sha1
  $ curl -i http://localhost:8080/ivys/org.rubygems/ivy-cucumber-1.0.0.xml
  $ curl -i http://localhost:8080/ivys/org.rubygems/ivy-cucumber-1.0.0.xml.md5
  $ curl -i http://localhost:8080/ivys/org.rubygems/ivy-cucumber-1.0.0.xml.sha1
  ```

Hooking it up with ivy
----------------------

1) In your `ivysettings.xml`, set up the following resolver:

```xml
<ivysettings>
  ...
  <url name="gems">
    <ivy pattern="http://localhost:8080/ivys/[organization]/ivy-[module]-[revision].xml" />
    <artifact pattern="http://localhost:8080/jars/[organization]/[module]-[revision].jar" />
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

Where's it at?
-------------
**THIS IS A PROTOTYPE**

### DONE-ISH ###
* Construction of jruby compatible gemjars. 
* Construction of ivy modules based on the gemspec. 
* MD5 and SHA1 of all constructed artifacts. 
* Can be built as a war.

### SOON-ISH ###
* Maven `pom.xml` generation.
* Tests

### HOW CAN YOU HELP ###
* Try it out.
* Give me feed back.
