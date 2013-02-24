RecipientInterceptor
====================

[![Build Status](https://secure.travis-ci.org/croaky/recipient_interceptor.png)](http://travis-ci.org/croaky/recipient_interceptor?branch=master)
[![Code Quality](https://codeclimate.com/badge.png)](https://codeclimate.com/github/croaky/recipient_interceptor)

Use RecipientInterceptor when you don't want your Ruby program to accidentally
send emails to addresses other than those on a whitelist which you configure.

Rails example
-------------

Send all staging emails to a group email address without accidentally emailing
users with active email addresses in the database.

`Gemfile`:

    gem 'recipient_interceptor'

`config/environments/staging.rb`:

    Mail.register_interceptor RecipientInterceptor.new(ENV['EMAIL_RECIPIENTS'])

Command line:

    heroku config:add EMAIL_RECIPIENTS="staging@example.com" --remote staging

Credits
-------

RecipientInterceptor is maintained by Dan Croak and
[contributors](/croaky/recipient_interceptor/contributors) like you.

License
-------

RecipientInterceptor is © 2013 Dan Croak. It is free software, and may be
redistributed under the terms specified in the `LICENSE` file.
