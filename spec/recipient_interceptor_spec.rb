require File.join(File.dirname(__FILE__), "..", "lib", "recipient_interceptor")

describe RecipientInterceptor do
  before do
    Mail.defaults do
      delivery_method :test
    end

    module Mail
      @@delivery_interceptors = []
    end
  end

  it "overrides to/cc/bcc fields and adds custom headers" do
    Mail.register_interceptor(
      RecipientInterceptor.new("staging@example.com")
    )

    mail = Mail.deliver {
      from "from@example.com"
      to "to@example.com"
      cc "cc@example.com"
      bcc "bcc@example.com"
      subject "some subject"
    }

    expect(mail.to).to eq ["staging@example.com"]
    expect(mail.cc).to eq nil
    expect(mail.bcc).to eq nil
    expect(mail.header["X-Intercepted-To"].to_s).to eq "to@example.com"
    expect(mail.header["X-Intercepted-Cc"].to_s).to eq "cc@example.com"
    expect(mail.header["X-Intercepted-Bcc"].to_s).to eq "bcc@example.com"
  end

  it "overrides to/cc/bcc even if they were already missing" do
    Mail.register_interceptor(
      RecipientInterceptor.new("staging@example.com")
    )

    mail = Mail.deliver {
      from "from@example.com"
      to "to@example.com"
    }

    expect(mail.to).to eq ["staging@example.com"]
    expect(mail.cc).to eq nil
    expect(mail.bcc).to eq nil
  end

  it "accepts an array of recipients" do
    Mail.register_interceptor(
      RecipientInterceptor.new(["one@example.com", "two@example.com"])
    )

    mail = Mail.deliver {
      from "from@example.com"
      to "to@example.com"
      cc "cc@example.com"
      bcc "bcc@example.com"
      subject "some subject"
    }

    expect(mail.to).to eq ["one@example.com", "two@example.com"]
  end

  it "accepts a comma-delimited list of recipients" do
    Mail.register_interceptor(
      RecipientInterceptor.new("one@example.com,two@example.com")
    )

    mail = Mail.deliver {
      from "from@example.com"
      to "to@example.com"
      subject "some subject"
    }

    expect(mail.to).to eq ["one@example.com", "two@example.com"]
  end

  it "does not prefix subject by default" do
    Mail.register_interceptor(
      RecipientInterceptor.new("staging@example.com")
    )

    mail = Mail.deliver {
      from "from@example.com"
      to "to@example.com"
      subject "some subject"
    }

    expect(mail.subject).to eq "some subject"
  end

  it "prefixes subject with string" do
    Mail.register_interceptor(
      RecipientInterceptor.new(
        "staging@example.com",
        subject_prefix: "[staging]"
      )
    )

    mail = Mail.deliver {
      from "from@example.com"
      to "to@example.com"
      subject "some subject"
    }

    expect(mail.subject).to eq "[staging] some subject"
  end

  it "prefixes subject with proc" do
    Mail.register_interceptor(
      RecipientInterceptor.new(
        "staging@example.com",
        subject_prefix: proc { |msg| "[staging] [#{(msg.to + msg.cc + msg.bcc).sort.join(",")}]" }
      )
    )

    mail = Mail.deliver {
      from "from@example.com"
      to ["to1@example.com", "to2@example.com"]
      cc "cc@example.com"
      bcc "bcc@example.com"
      subject "some subject"
    }

    expect(mail.subject).to eq "[staging] [bcc@example.com,cc@example.com,to1@example.com,to2@example.com] some subject"
  end
end
