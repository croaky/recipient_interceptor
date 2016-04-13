require 'mail'

class RecipientInterceptor
  def initialize(recipients, options = {})
    @recipients = normalize_to_array(recipients)
    @subject_prefix = options[:subject_prefix]
    @subject_list_recipients = options[:subject_list_recipients]
  end

  def delivering_email(message)
    add_custom_headers message
    add_subject_prefix message
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

  def add_subject_prefix(message)
    new_subject = []
    new_subject.push(@subject_prefix) if @subject_prefix
     if @subject_list_recipients
      [:to, :cc, :bcc].each do |type|
        new_subject.push("[#{type}: #{message.send(type).join(", ")}]") if message.send(type)
      end
    end
    new_subject.push(message.subject)
    message.subject = new_subject.join(" ")
  end

  def add_custom_headers(message)
    {
      'X-Intercepted-To' => message.to || [],
      'X-Intercepted-Cc' => message.cc || [],
      'X-Intercepted-Bcc' => message.bcc || []
    }.each do |header, addresses|
      addresses.each do |address|
        message.header = "#{message.header}#{header}: #{address}"
      end
    end
  end
end
