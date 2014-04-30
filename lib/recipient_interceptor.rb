require 'mail'

class RecipientInterceptor

  def initialize(recipients, options = {})
    @recipients = normalize_to_array(recipients)
    @email_whitelist = options[:email_whitelist] || []
    @domain_whitelist = options[:domain_whitelist] || []
    @subject_prefix = options[:subject_prefix]
  end

  def delivering_email(message)
    add_custom_headers message
    add_subject_prefix message
    message.to = sanitize_recipients(message)
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
      addresses.each do |address|
        message.header = "#{message.header}#{header}: #{address}"
      end
    end
  end

  def sanitize_recipients(message)
    recipients = message.to
    sanitized_recipients = recipients.select { |email| whitelisted?(email) }
    sanitized_recipients.any? ? sanitized_recipients : @recipients
  end

  def whitelisted?(email)
    whitelisted_email?(email) || whitelisted_domain?(email)
  end

  def whitelisted_email?(email)
    @email_whitelist.include?(email)
  end

  def whitelisted_domain?(email)
    @domain_whitelist.any? do |domain|
      email =~ /@#{domain}$/
    end
  end

end
