# Carbon AWS SES Adapter

![Build Status](https://github.com/keizo3/carbon_aws_ses_adapter/workflows/Shard%20CI/badge.svg)

This is luckyframework/carbon's adapter for [AWS SES (Simple Email Service)](https://aws.amazon.com/ses/)

https://github.com/luckyframework/carbon

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  carbon_aws_ses_adapter:
    github: keizo3/carbon_aws_ses_adapter
```

Add this to your application's `shards.cr`:

```crystal
require "carbon_aws_ses_adapter"
```

## Usage

### Configure AWS SES Simple Email Service

1. Go to the [Amazon Web Services developer console](https://console.aws.amazon.com/).
1. Ensure that AWS SES is correctly set up according to [the documentation](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/send-email-set-up.html).
1. Create an AWS IAM user who can send emails. The user must have at least the following permissions:
   - `ses:SendEmail`
   - `ses:SendRawEmail`
1. Copy the AWS Access Key and AWS Secret Access key for the IAM user you've created.
1. Set up the adapter in Lucky via the `config/email.cr` file.

### Configure the mailer class

```crystal
# config/email.cr

BaseEmail.configure do
  settings.adapter = Carbon::AwsSesAdapter.new(
    key:    ENV["AWS_SES_ACCESS_KEY"],
    secret: ENV["AWS_SES_SECRET_KEY_KEY"],
    region: ENV["AWS_SES_REGION"]
  )
end
```

## Development

- `shards install`
- Make changes
- `crystal spec` (will skip sending test emails to AWS SES)
- `crystal spec -D send_real_email` (will send real emails, and requires the below `.env` file content)

```
# In .env
# If you want to run tests that actually test emails against the AWS SES
AWS_SES_ACCESS_KEY=get_from_aws_ses_key
AWS_SES_SECRET_KEY=get_from_aws_ses_secret
AWS_SES_REGION=get_from_aws_ses_region
AWS_SES_FROM_ADDRESS=verified_address
AWS_SES_TO_ADDRESS=recipient_address
```

## Contributing

1.  Fork it ( https://github.com/keizo3/carbon_aws_ses_adapter )
2.  Create your feature branch (git checkout -b my-new-feature)
3.  Make your changes
4.  Run `./bin/test` to run the specs, build shards, and check formatting
5.  Commit your changes (git commit -am 'Add some feature')
6.  Push to the branch (git push origin my-new-feature)
7.  Create a new Pull Request

## Contributors

- [keizo3](https://github.com/keizo3) - creator, maintainer
