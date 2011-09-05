= capistrano-ext-params

== DESCRIPTION:

This package adds optional and required params to capistrano.

All required parameters are ensured to have a non-null value before the task executes, and all optional parameters will be validated against their :values.

== FEATURES/PROBLEMS:

* PROBLEM: does not build

== SYNOPSIS:

task :name, :roles => :server,
     :required => {
       :first_param => {
         :type => :string,
         :values => %w[ value_one value_two value_three]
       }
     },
     :optional => {
       :second_param => {
         :type => :number
       }
     } do

== REQUIREMENTS:

* capistrano

== INSTALL:

* gem install 'capistrano-ext-required-params'

== DEVELOPERS:

After checking out the source, run:

  $ rake newb

This task will install any missing dependencies, run the tests/specs,
and generate the RDoc.

== LICENSE:

(The MIT License)

Copyright (c) 2011 FIX

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
