RecipientInterceptor
====================

[![Build Status](https://secure.travis-ci.org/croaky/recipient_interceptor.png)](http://travis-ci.org/croaky/recipient_interceptor?branch=master)
[![Code Quality](https://codeclimate.com/badge.png)](https://codeclimate.com/github/croaky/recipient_interceptor)

Never accidentally send emails to real people from your staging environment.

Rails example
-------------

Send all staging emails to a group email address without accidentally emailing
users with active email addresses in the database.

In `Gemfile`:

    gem 'recipient_interceptor'

In `config/environments/staging.rb`:

    Mail.register_interceptor RecipientInterceptor.new(ENV['EMAIL_RECIPIENTS'])

From the command line:

    heroku config:add EMAIL_RECIPIENTS="staging@example.com" --remote staging

Options
-------

Optionally prefix the subject line:

    Mail.register_interceptor RecipientInterceptor.new(
      ENV['EMAIL_RECIPIENTS'],
      subject_prefix: '[STAGING]'
    )

Optionally white-list emails:

    Mail.register_interceptor RecipientInterceptor.new(
      ENV['EMAIL_RECIPIENTS'],
      email_whitelist: ['whitelisted@example.com']
    )

Optionally white-list domains:

    Mail.register_interceptor RecipientInterceptor.new(
      ENV['EMAIL_RECIPIENTS'],
      domain_whitelist: ['example.com']
    )

Note: If one or more of the original recipients match the email white-list or domain white-list,
the email's to field will not be overridden. However, non-white-listed emails will be removed from
the email's to field.

Credits
-------

RecipientInterceptor is maintained by Dan Croak and
[contributors](/croaky/recipient_interceptor/contributors) like you.

License
-------

RecipientInterceptor is © 2013 Dan Croak. It is free software, and may be
redistributed under the terms specified in the `LICENSE` file.
