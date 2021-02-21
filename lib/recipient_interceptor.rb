require "mail"

class RecipientInterceptor
  def initialize(recipients, opts = {})
    @recipients = if recipients.respond_to?(:split)
      recipients.split(",")
    else
      recipients
    end

    @subject_prefix = opts[:subject_prefix]
  end

  def delivering_email(msg)
    if @subject_prefix.respond_to?(:call)
      msg.subject = "#{@subject_prefix.call(msg)} #{msg.subject}"
    elsif @subject_prefix
      msg.subject = "#{@subject_prefix} #{msg.subject}"
    end

    msg.header["X-Intercepted-To"] = msg.to || []
    msg.header["X-Intercepted-Cc"] = msg.cc || []
    msg.header["X-Intercepted-Bcc"] = msg.bcc || []

    msg.to = @recipients
    msg.cc = nil if msg.cc
    msg.bcc = nil if msg.bcc
  end
end
