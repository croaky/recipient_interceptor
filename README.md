RecipientInterceptor
====================

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

