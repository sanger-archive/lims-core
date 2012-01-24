<!-- vim: spell:spelllang=en tw=80
Yard markup
# @markup markdown
# @title README
-->

Overview 
=======

This gem implements the core functionalities of the LIMS (Laboratory Information Management System).
It's not meant to be a stand alone application but the core library of the LIMS
server.

For more information consult the documentation.

Installation
============

    gem install lims-core

Or, if you are using [bundler](http://gembundler.com/) , add the following line

     gem :lims-core, :git => "git+ssh://git@github.com/sanger/lims-core.git'

in your `Gemfile`.

Documentation
=============
The documentation is generated using [yard](http://yardoc.org/index.html) and can
be found under the `doc/` directory or using a `yard server`

Developers Guide
================
Documentation Guide
-------------------

The documentation is written using [yard](http://yardoc.org/index.html).
It allows to write documentation within the doc and add *typing* hints/
expectations.
The recommended format for stand alone documentation files is
[markdown](http://daringfireball.net/projects/markdown/), however
it's easier to keep the native markup language used by **yard**, i.e. the
[rdoc](http://rdoc.sourceforge.net/) one.
This allows the code to be parsed via **rdoc** and doesn't need the extra spaces at
the end of a line needed by **markdown**.

However, when the usage of pure **markdown** seems appropriate, it's still
possible to the use `@markup` switch.

Some documentation can also be added in the specs.

Tests
-----
We are using [rspec](http://rspec.info/).
