require 'mail'

class RecipientInterceptor

  def self.recipients=(recipients)
    @@recipients = if recipients.respond_to? :split
      recipients.split ','
    else
      recipients
    end
  end

  def self.recipients
    @@recipients ||= []
  end

  def self.delivering_email(message)
    message     = add_custom_headers(message)
    message.to  = recipients
    message.cc  = []
    message.bcc = []
  end

  private

  def self.add_custom_headers(message)
    {
      'X-Intercepted-To' => message.to,
      'X-Intercepted-Cc' => message.cc,
      'X-Intercepted-Bcc' => message.bcc
    }.each do |header, addresses|
      addresses.each do |address|
        message.header = "#{message.header}\n#{header}: #{address}"
      end if addresses
    end

    message
  end
end
