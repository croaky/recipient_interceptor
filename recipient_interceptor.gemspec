Gem::Specification.new do |spec|
  spec.add_dependency 'mail'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.authors = ['Dan Croak']

  spec.description = <<-eos
    Use RecipientInterceptor when you don't want your Ruby program to
    accidentally send emails to addresses other than those on a whitelist
    which you configure. For example, you could use it in your web app's
    staging environment.
  eos

  spec.email = 'dan@thoughtbot.com'
  spec.files = ['lib/recipient_interceptor.rb']
  spec.homepage = 'http://github.com/croaky/recipient_interceptor'
  spec.license = 'MIT'
  spec.name = 'recipient_interceptor'
  spec.require_paths = ['lib']
  spec.summary = 'Intercept recipients when delivering email with the Mail gem.'
  spec.test_files = ['spec/recipient_interceptor_spec.rb']
  spec.version = '0.1.1'
end
