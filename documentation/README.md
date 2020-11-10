Introduction
==================
The intent of the documentation directory is to provide a location for documentation related to the data science pipeline. It
leverages AsciiDoc to generate manuals, tutorials, and guides.

AsciiDoc is a tool for generating uniform documentation with proper version control independent of the presentation.
For more information visit the [AsciiDoc Overview](https://asciidoctor.org/docs/what-is-asciidoc/).


Prerequisites
=============

Since we are using the [Gradle
Wrapper](https://docs.gradle.org/current/userguide/gradle_wrapper.html),
the only requirement is to have
[Java](https://www.java.com/fr/download/) installed.

> A Java version between 8 and 13 is required to execute Gradle. Java 14
> and later versions are not yet supported.


Using the Gradle Wrapper
========================

On Windows, open a terminal and type:

    $ gradlew.bat

On Linux and macOS, open a terminal and type:

    $ ./gradlew

If you run this command for the first time it will download and install
Gradle and execute a build generating documentation. Make sure you have unrestricted access to the Internet (ie.
not behind a corporate proxy).

Tasks
=====

In the following examples, we are going to use the command `./gradlew`.

If you are using Windows, don’t forget to replace `./gradlew` by
`gradlew.bat`.

**Convert to HTML.**

    $ ./gradlew convertOnlineHtml

**Convert to PDF.**

    $ ./gradlew convertOnlinePdf

All the generated files will be available at
*documentation/asciidoc/build*.

If you want to convert all the files at once, you can use the `convert`
task:

    $ ./gradlew convert


Or multiple tasks:

    $ ./gradlew convertOnlinePdf convertOnlineHtml

Gradle will do its best to detect if a task needs to be run again or
not. If you want to force Gradle to execute a task again, you can remove
the `build` directory using the `clean` task:

    $ ./gradlew clean

Once the `build` directory is removed, type the task you want to
execute.


LiveReload
==========

To enable [LiveReload](http://livereload.com/), you will need to install
the [LiveReload browser
extension](https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei?hl=en)
on Chrome. 

Next, you need to open two terminals. In the first one, type the
following command to continuously convert the AsciiDoc source to a
reveal.js presentation:

    $ ./gradlew --continuous convertSlides

On the second one, type the following command to start the LiveReload
server

    $ ./gradlew liveReload

    > Task :liveReload
    Enabling LiveReload at port 35729 for /path/to/asciidoc/build

You’re all set!

Now, open Chrome and navigate to the HTML file of your choice, for
instance:
<http://localhost:35729/online/index.html>.
Don’t forget to enable the LiveReload extension on your browser by
clicking on the icon. (Notice that the middle circle is now filled in black.)

If you edit the corresponding AsciiDoc source (or resources) and wait a
few seconds, your browser will automatically be refreshed with your
changes.

Similarly, you can use LiveReload with the online training using:

    $ ./gradlew --continuous convertOnlineHtml -Penv=dev
