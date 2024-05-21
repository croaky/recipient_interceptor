Gem::Specification.new do |spec|
  spec.add_dependency "mail"
  spec.authors = ["Dan Croak"]

  spec.description = <<-STRING
    Avoid emailing your users from non-production environments.
  STRING

  spec.files = ["lib/recipient_interceptor.rb"]
  spec.homepage = "http://github.com/croaky/recipient_interceptor"
  spec.license = "MIT"
  spec.name = "recipient_interceptor"
  spec.require_paths = ["lib"]
  spec.summary = "Intercept recipients when delivering email with the Mail gem."
  spec.version = "0.3.2"
end
