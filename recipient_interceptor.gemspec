Gem::Specification.new do |s|
  s.name = 'recipient_interceptor'
  s.version = '0.1.1'
  s.authors = ['Dan Croak']
  s.email = 'dan@thoughtbot.com'
  s.homepage = 'http://github.com/croaky/recipient_interceptor'
  s.summary = 'Intercept recipients when delivering email with the Mail gem.'
  s.description = <<-eos
    Use RecipientInterceptor when you don't want your Ruby program to
    accidentally send emails to addresses other than those on a whitelist
    which you configure. For example, you could use it in your web app's
    staging environment.
  eos

  s.files = ['lib/recipient_interceptor.rb']
  s.test_files = ['spec/recipient_interceptor_spec.rb']
  s.require_paths = ['lib']

  s.add_dependency 'mail'
  s.add_development_dependency 'rspec'
end
