require File.join(File.dirname(__FILE__), '..', 'lib', 'recipient_interceptor')

describe RecipientInterceptor do
  it 'overrides to/cc/bcc fields' do
    Mail.register_interceptor RecipientInterceptor.new(recipient_string)

    response = deliver_mail

    expect(response.to).to eq [recipient_string]
    expect(response.cc).to eq []
    expect(response.bcc).to eq []
  end

  it 'copies original to/cc/bcc fields to custom headers' do
    Mail.register_interceptor RecipientInterceptor.new(recipient_string)

    response = deliver_mail

    expect(custom_header(response, 'X-Intercepted-To')).
      to eq 'original.to@example.com'
    expect(custom_header(response, 'X-Intercepted-Cc')).
      to eq 'original.cc@example.com'
    expect(custom_header(response, 'X-Intercepted-Bcc')).
      to eq 'original.bcc@example.com'
  end

  it 'accepts an array of recipients' do
    Mail.register_interceptor RecipientInterceptor.new(recipient_array)

    response = deliver_mail

    expect(response.to).to eq recipient_array
  end

  it 'accepts a string of recipients' do
    Mail.register_interceptor RecipientInterceptor.new(recipient_string)

    response = deliver_mail

    expect(response.to).to eq [recipient_string]
  end

  context 'given an email white-list' do
    context 'for emails with one recipient' do
      it 'does not override the to field for a white-listed email' do
        Mail.register_interceptor RecipientInterceptor.new(
          'override@whitelisted.com',
          email_whitelist: ['original@whitelisted.com']
        )

        response = deliver_mail to: 'original@whitelisted.com'
        expect(response.to).to eq ['original@whitelisted.com']
      end

      it 'overrides the to field for a non-white-listed email' do
        Mail.register_interceptor RecipientInterceptor.new(
          'override@whitelisted.com',
          email_whitelist: ['original@whitelisted.com']
        )

        response = deliver_mail to: 'original@blacklisted.com'
        expect(response.to).to eq ['override@whitelisted.com']
      end
    end

    context 'for emails with multiple recipients' do
      it 'strips non-white-listed emails, leaving white-listed ones' do
        Mail.register_interceptor RecipientInterceptor.new(
          'override@whitelisted.com',
          email_whitelist: ['original@whitelisted.com']
        )

        response = deliver_mail to: ['original@whitelisted.com', 'other@whitelisted.com']
        expect(response.to).to eq ['original@whitelisted.com']
      end

      it 'replaces all recipients when none is white-listed' do
        Mail.register_interceptor RecipientInterceptor.new(
          'override@whitelisted.com',
          email_whitelist: ['original@whitelisted.com']
        )

        response = deliver_mail to: ['original@blacklisted.com', 'other@whitelisted.com']
        expect(response.to).to eq ['override@whitelisted.com']
      end
    end
  end

  context 'given an domain white-list' do
    context 'for emails with one recipient' do
      it 'does not override the to field for a white-listed email' do
        Mail.register_interceptor RecipientInterceptor.new(
          'override@whitelisted.com',
          domain_whitelist: ['whitelisted.com']
        )

        response = deliver_mail to: 'original@whitelisted.com'
        expect(response.to).to eq ['original@whitelisted.com']
      end

      it 'overrides the to field for a non-white-listed email' do
        Mail.register_interceptor RecipientInterceptor.new(
          'override@whitelisted.com',
          domain_whitelist: ['whitelisted.com']
        )

        response = deliver_mail to: 'original@blacklisted.com'
        expect(response.to).to eq ['override@whitelisted.com']
      end
    end

    context 'for emails with multiple recipients' do
      it 'strips non-white-listed emails, leaving white-listed ones' do
        Mail.register_interceptor RecipientInterceptor.new(
          'override@whitelisted.com',
          domain_whitelist: ['whitelisted.com']
        )

        response = deliver_mail to: ['original@whitelisted.com', 'other@whitelisted.com', 'other@blacklisted.com']
        expect(response.to).to eq ['original@whitelisted.com', 'other@whitelisted.com']
      end

      it 'replaces all recipients when none is white-listed' do
        Mail.register_interceptor RecipientInterceptor.new(
          'override@whitelisted.com',
          domain_whitelist: ['whitelisted.com']
        )

        response = deliver_mail to: ['original@blacklisted.com', 'other@blacklisted.com']
        expect(response.to).to eq ['override@whitelisted.com']
      end
    end
  end

  it 'does not prefix subject by default' do
    Mail.register_interceptor RecipientInterceptor.new(recipient_string)

    response = deliver_mail

    expect(response.subject).to eq 'some subject'
  end

  it 'prefixes subject when given' do
    Mail.register_interceptor RecipientInterceptor.new(
      recipient_string,
      subject_prefix: '[STAGING]'
    )

    response = deliver_mail

    expect(response.subject).to eq '[STAGING] some subject'
  end

  def recipient_string
    'staging@example.com'
  end

  def recipient_array
    ['one@example.com', 'two@example.com']
  end

  def deliver_mail(options = {})
    Mail.defaults do
      delivery_method :test
    end

    Mail.deliver do
      from options.fetch(:from, 'original.from@example.com')
      to options.fetch(:to, 'original.to@example.com')
      cc options.fetch(:cc, 'original.cc@example.com')
      bcc options.fetch(:bcc, 'original.bcc@example.com')
      subject options.fetch(:subject, 'some subject')
    end
  end

  def custom_header(response, name)
    header = response.header[name]

    if header.respond_to?(:map)
      header.map { |h| h.value.wrapped_string }
    else
      header.to_s
    end
  end

  after do
    module Mail
      @@delivery_interceptors = []
    end
  end
end
