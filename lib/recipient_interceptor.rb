require 'mail'

class RecipientInterceptor
  def initialize(recipients)
    @recipients = normalize_to_array(recipients)
  end

  def delivering_email(message)
    add_custom_headers message
    message.to = @recipients
    message.cc = []
    message.bcc = []
  end

  private

  def normalize_to_array(recipients)
    if recipients.respond_to? :split
      recipients.split ','
    else
      recipients
    end
  end

  def add_custom_headers(message)
    {
      'X-Intercepted-To' => message.to || [],
      'X-Intercepted-Cc' => message.cc || [],
      'X-Intercepted-Bcc' => message.bcc || []
    }.each do |header, addresses|
      addresses.each do |address|
        message.header = "#{message.header}\n#{header}: #{address}"
      end
    end
  end
end
