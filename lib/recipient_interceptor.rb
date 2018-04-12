require 'mail'

class RecipientInterceptor
  def initialize(recipients, options = {})
    @recipients = normalize_to_array(recipients)
    @subject_prefix = options[:subject_prefix]
  end

  def delivering_email(message)
    add_custom_headers message
    add_subject_prefix message
    message.to = @recipients
    message.cc = nil if message.cc
    message.bcc = nil if message.bcc
  end

  private

  def normalize_to_array(recipients)
    if recipients.respond_to? :split
      recipients.split ','
    else
      recipients
    end
  end

  def add_subject_prefix(message)
    if @subject_prefix
      message.subject = "#{@subject_prefix} #{message.subject}"
    end
  end

  def add_custom_headers(message)
    {
      'X-Intercepted-To' => message.to || [],
      'X-Intercepted-Cc' => message.cc || [],
      'X-Intercepted-Bcc' => message.bcc || []
    }.each do |header, addresses|
      message.header[header] = addresses
    end
  end
end
