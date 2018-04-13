require File.join(File.dirname(__FILE__), '..', 'lib', 'recipient_interceptor')

describe RecipientInterceptor do
  let(:recipient_string) { 'staging@example.com' }
  let(:recipient_array) { ['one@example.com', 'two@example.com'] }

  before do
    Mail.defaults do
      delivery_method :test
    end
  end

  after do
    module Mail
      @@delivery_interceptors = []
    end
  end

  it 'overrides to/cc/bcc fields' do
    Mail.register_interceptor RecipientInterceptor.new(recipient_string)

    response = deliver_mail

    expect(response.to).to eq [recipient_string]
    expect(response.cc).to eq nil
    expect(response.bcc).to eq nil
  end

  it 'overrides to/cc/bcc correctly even if they were already missing' do
    Mail.register_interceptor RecipientInterceptor.new(recipient_string)

    response = Mail.deliver do
      from 'original.from@example.com'
      to 'original.to@example.com'
    end

    expect(response.to).to eq [recipient_string]
    expect(response.cc).to eq nil
    expect(response.bcc).to eq nil
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

  def deliver_mail
    Mail.deliver do
      from 'original.from@example.com'
      to 'original.to@example.com'
      cc 'original.cc@example.com'
      bcc 'original.bcc@example.com'
      subject 'some subject'
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
end
