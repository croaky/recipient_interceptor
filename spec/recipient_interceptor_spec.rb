require File.join(File.dirname(__FILE__), '..', 'lib', 'recipient_interceptor')

describe RecipientInterceptor do
  it 'overrides to/cc/bcc fields, copies original fields to custom headers' do
    Mail.register_interceptor RecipientInterceptor.new('staging@example.com')

    response = deliver_mail

    expect(response.to).to eq ['staging@example.com']
    expect(response.cc).to eq []
    expect(response.bcc).to eq []

    expect(response.header['X-Intercepted-To'].to_s).
      to eq "[original.to@example.com, staging@example.com]"
    expect(response.header['X-Intercepted-Cc'].to_s).
      to eq 'original.cc@example.com'
    expect(response.header['X-Intercepted-Bcc'].to_s).
      to eq 'original.bcc@example.com'
  end

  it 'accepts an array of recipients' do
    Mail.register_interceptor RecipientInterceptor.new(recipient_array)

    response = deliver_mail

    expect(response.to).to eq recipient_array
  end

  def deliver_mail
    Mail.defaults do
      delivery_method :test
    end

    Mail.deliver do
      from 'original.from@example.com'
      to 'original.to@example.com'
      cc 'original.cc@example.com'
      bcc 'original.bcc@example.com'
    end.deliver!
  end

  def recipient_array
    ['one@example.com', 'two@example.com']
  end
end
