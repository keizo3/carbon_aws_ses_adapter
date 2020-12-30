# carbon_aws_ses_adapter

![Build Status](https://github.com/keizo3/carbon_aws_ses_adapter/workflows/Shard%20CI/badge.svg)

This is luckyframework/carbon's adapter for AWS SES

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

### Configure the mailer class

1. setting AWS SES on your AWS Console
2. create iam user for send AWS SES on your AWS Console
3. get iam user credentials
4. setting adapter

```crystal
require "carbon_aws_ses_adapter"

BaseEmail.configure do
  settings.adapter = Carbon::AwsSesAdapter.new(key: ENV["AWS_SES_KEY"], secret: ENV["AWS_SES_SECRET"], region: ENV["AWS_SES_REGION"])
end
```

## Development

- `shards install`
- Make changes
- `crystal spec` (will skip sending test emails to AWS SES)
- `crystal spec -D send_real_email` requires a `AWS_SES_KEY` `AWS_SES_SECRET` `AWS_SES_REGION` ENV variable. Set this in a .env file:

```
# in .env
# If you want to run tests that actually test emails against the AWS SES
AWS_SES_KEY=get_from_aws_ses_key
AWS_SES_SECRET=get_from_aws_ses_secret
AWS_SES_REGION=get_from_aws_ses_region
AWS_SES_FROM_ADDRESS=verified_address
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
