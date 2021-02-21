# RecipientInterceptor

Avoid accidentally emailing users from your staging environment.

```ruby
# Gemfile
gem "recipient_interceptor"
```

## Configuration options and examples

Deliver intercepted email to a group email address `staging@example.com`:

```ruby
# config/environments/staging.rb
Mail.register_interceptor(
  RecipientInterceptor.new("staging@example.com")
)
```

Deliver intercepted email to multiple email addresses:

```ruby
Mail.register_interceptor(
  RecipientInterceptor.new("one@example.com,two@example.com")
)
```

Use an environment variable:

```ruby
# heroku config:set EMAIL_RECIPIENTS="one@example.com,two@example.com" --app staging
Mail.register_interceptor(
  RecipientInterceptor.new(ENV["EMAIL_RECIPIENTS"])
)
```

Prefix the subject line with static text:

```ruby
Mail.register_interceptor(
  RecipientInterceptor.new(
    ENV["EMAIL_RECIPIENTS"],
    subject_prefix: "[staging]",
  ),
)
```

Prefix the subject line with contents from the original message:

```ruby
Mail.register_interceptor(
  RecipientInterceptor.new(
    ENV["EMAIL_RECIPIENTS"],
    subject_prefix: proc { |msg| "[staging] [#{(msg.to + msg.cc + msg.bcc).sort.join(",")}]" }
  ),
)
```

The object passed to the proc is an instance of
[`Mail::Message`](https://www.rubydoc.info/github/mikel/mail/Mail/Message).

## Contributing

Fork the repo.

```
bundle
bundle exec rake
```

Make a change.
Run tests.
Open a pull request.
Discuss/address any feedback with maintainer.
Maintainer will merge.
