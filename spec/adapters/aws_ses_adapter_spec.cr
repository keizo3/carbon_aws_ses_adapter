require "../spec_helper"

describe "AwsSES adapter" do
  {% if flag?("send_real_email") %}
    describe "deliver_now" do
      it "delivers the email successfully" do
        send_email_to_aws_ses text_body: "This is a test sent from https://keizo3/carbon_aws_ses_adapter."
      end

      it "delivers emails with reply_to set" do
        send_email_to_aws_ses text_body: "This is a test sent from https://keizo3/carbon_aws_ses_adapter.",
          headers: {"Reply-To" => ENV.fetch("AWS_SES_TO_ADDRESS")}
      end
    end
  {% end %}

  describe "params" do
    it "is not sandboxed by default" do
      params_for[:mail_settings][:sandbox_mode][:enable].should be_false
    end

    it "handles headers" do
      headers = {"Header1" => "value1", "Header2" => "value2"}
      params = params_for(headers: headers)

      params[:headers].should eq headers
    end

    it "create authorization" do
      params_for()[:authorization].should eq "AWS4-HMAC-SHA256 Credential=fake_key/20190102/fake_region/ses/aws4_request, SignedHeaders=content-type;host;x-amz-date, Signature=7f0bbf212f6f9e232dde0e0917be4d296a328459e051f9032e725d9c13af8264"
    end

    it "create k_signing" do
      params_for()[:k_signing].should eq Bytes[138, 105, 91, 139, 163, 41, 143, 208, 156, 109, 198, 29, 48, 103, 200, 242, 126, 145, 93, 82, 78, 147, 212, 82, 63, 176, 190, 165, 57, 173, 63, 228]
    end

    it "create m_signing" do
      params_for()[:m_signing].should eq "AWS4-HMAC-SHA256\n20190102T154556Z\n20190102/fake_region/ses/aws4_request\ne0c5ef7baf80c18a6805b9f9d4a66c17fcb8de436686d61d5e328f499dae080a"
    end

    it "create canonical_string" do
      params_for()[:canonical_string].should eq "POST\n/\n\ncontent-type:application/x-www-form-urlencoded; charset=utf-8\nhost:email.fake_region.amazonaws.com\nx-amz-date:20190102T154556Z\n\ncontent-type;host;x-amz-date\n898544300f10156174ad93313e7259be9e8f17e5dd21a60cfa845fa56d8479a9"
    end

    it "hash256" do
      params_for()[:hash256].should eq "15a3d569fd04cd38f2ac750d7b3ad08e621845ad2fef52fe4bc6ebdab375f831"
    end

    it "sets extracts reply-to header" do
      headers = {"reply-to" => "noreply@example.com", "Header" => "value"}
      params = params_for(headers: headers)

      params[:headers].should eq({"Header" => "value"})
      params[:reply_to].should eq "noreply@example.com"
    end

    it "sets extracts reply-to header regardless of case" do
      headers = {"Reply-To" => "noreply@example.com", "Header" => "value"}
      params = params_for(headers: headers)

      params[:headers].should eq({"Header" => "value"})
      params[:reply_to].should eq "noreply@example.com"
    end

    it "handles send_mail_params" do
      params_for()[:send_mail_params].should eq "Action=SendEmail&Source=%3Cfrom%40example.com%3E&Message.Subject.Data=%5BCarbonAwsSesAdapter%5D%20Test%20Email"
    end

    it "handles send_mail_params multi addresses with name" do
      from_address = Carbon::Address.new("Sally", "from@example.com")
      to_without_name = Carbon::Address.new("to@example.com")
      to_with_name = Carbon::Address.new("Jimmy", "to2@example.com")
      cc_without_name = Carbon::Address.new("cc@example.com")
      cc_with_name = Carbon::Address.new("Kim", "cc2@example.com")
      bcc_without_name = Carbon::Address.new("bcc@example.com")
      bcc_with_name = Carbon::Address.new("James", "bcc2@example.com")

      multiaddress_params = params_for(
        from: from_address,
        to: [to_without_name, to_with_name],
        cc: [cc_without_name, cc_with_name],
        bcc: [bcc_without_name, bcc_with_name]
      )

      multiaddress_params[:send_mail_params].should eq "Action=SendEmail&Source=Sally%20%3Cfrom%40example.com%3E&Destination.ToAddresses.member.1=%3Cto%40example.com%3E&Destination.ToAddresses.member.2=Jimmy%20%3Cto2%40example.com%3E&Destination.CcAddresses.member.1=%3Ccc%40example.com%3E&Destination.CcAddresses.member.2=Kim%20%3Ccc2%40example.com%3E&Destination.BccAddresses.member.1=%3Cbcc%40example.com%3E&Destination.BccAddresses.member.2=James%20%3Cbcc2%40example.com%3E&Message.Subject.Data=%5BCarbonAwsSesAdapter%5D%20Test%20Email"
    end

    it "sets the subject" do
      params_for(subject: "My subject")[:send_mail_params].should eq "Action=SendEmail&Source=%3Cfrom%40example.com%3E&Message.Subject.Data=My%20subject"
    end

    it "sets the message body" do
      params_for(text_body: "text")[:send_mail_params].should eq "Action=SendEmail&Source=%3Cfrom%40example.com%3E&Message.Subject.Data=%5BCarbonAwsSesAdapter%5D%20Test%20Email&Message.Body.Text.Data=text"
      params_for(html_body: "html")[:send_mail_params].should eq "Action=SendEmail&Source=%3Cfrom%40example.com%3E&Message.Subject.Data=%5BCarbonAwsSesAdapter%5D%20Test%20Email&Message.Body.Html.Data=html"
      params_for(text_body: "text", html_body: "html")[:send_mail_params].should eq "Action=SendEmail&Source=%3Cfrom%40example.com%3E&Message.Subject.Data=%5BCarbonAwsSesAdapter%5D%20Test%20Email&Message.Body.Text.Data=text&Message.Body.Html.Data=html"
    end
  end
end

private def params_for(**email_attrs)
  email = FakeEmail.new(**email_attrs)
  region = "fake_region"
  date = Time.utc(2019, 1, 2, 15, 45, 56).to_s("%Y%m%dT%H%M%SZ")
  adapter = Carbon::AwsSesAdapter::Email.new(email, key: "fake_key", secret: "fake_secret", region: region)

  # fix mail send date
  adapter.date = date
  adapter.credential_scope = "#{date.split("T")[0]}/#{region}/ses/aws4_request"
  adapter.params
end

private def send_email_to_aws_ses(**email_attrs)
  key = ENV.fetch("AWS_SES_ACCESS_KEY")
  secret = ENV.fetch("AWS_SES_SECRET_KEY")
  region = ENV.fetch("AWS_SES_REGION")
  from_address = ENV.fetch("AWS_SES_FROM_ADDRESS", "from@example.com")
  to_address = ENV.fetch("AWS_SES_TO_ADDRESS")

  email = FakeEmail.new(**email_attrs, to: [Carbon::Address.new(to_address)], from: Carbon::Address.new(from_address))
  adapter = Carbon::AwsSesAdapter.new(key: key, secret: secret, region: region, sandbox: true)

  adapter.deliver_now(email)
end
