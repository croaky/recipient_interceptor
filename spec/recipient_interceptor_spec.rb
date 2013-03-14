require File.join(File.dirname(__FILE__), '..', 'lib', 'recipient_interceptor')

describe RecipientInterceptor do
  it 'overrides to/cc/bcc fields' do
    Mail.register_interceptor(RecipientInterceptor)

    RecipientInterceptor.recipients = recipient_string

    response = deliver_mail

    expect(response.to).to eq [recipient_string]
    expect(response.cc).to eq []
    expect(response.bcc).to eq []
  end

  it 'copies original to/cc/bcc fields to custom headers' do
    Mail.register_interceptor(RecipientInterceptor)

    RecipientInterceptor.recipients = recipient_string

    response = deliver_mail

    expect(custom_header(response, 'X-Intercepted-To')).
      to eq 'original.to@example.com'
    expect(custom_header(response, 'X-Intercepted-Cc')).
      to eq 'original.cc@example.com'
    expect(custom_header(response, 'X-Intercepted-Bcc')).
      to eq 'original.bcc@example.com'
  end

  describe '.recipients=' do
    it 'accepts a string of recipients' do
      RecipientInterceptor.recipients = recipient_string

      expect(RecipientInterceptor.recipients).to eq [recipient_string]
    end

    it 'accepts an array of recipients' do
      RecipientInterceptor.recipients = recipient_array

      expect(RecipientInterceptor.recipients).to eq recipient_array
    end
  end

  def recipient_string
    'staging@example.com'
  end

  def recipient_array
    ['one@example.com', 'two@example.com']
  end

  def deliver_mail
    mail = Mail.new do
      from 'original.from@example.com'
      to   'original.to@example.com'
      cc   'original.cc@example.com'
      bcc  'original.bcc@example.com'
    end

    mail.delivery_method :test

    mail.deliver!
  end

  def custom_header(response, name)
    header = response.header[name]

    if header.respond_to?(:map)
      header.map {|header| header.value.wrapped_string }
    else
      header.to_s
    end
  end
end
