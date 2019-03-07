# carbon_aws_ses_adapter

[![Build Status](https://travis-ci.org/keizo3/carbon_aws_ses_adapter.svg?branch=master)](https://travis-ci.org/keizo3/carbon_aws_ses_adapter)

This is luckyframework/carbon's adapter for AWS SES

https://github.com/luckyframework/carbon

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  carbon_aws_ses_adapter:
    github: keizo3/carbon_aws_ses_adapter
```

## Usage

### Configure the mailer class

1. settint AWS SES on your AWS Console
2. get AWS credentials
3. setting adapter
```crystal
require "carbon_aws_ses_adapter"

BaseEmail.configure do
  settings.adapter = Carbon::AwsSesAdapter.new(key: ENV["AWS_SES_KEY"], secret: ENV["AWS_SES_SECRET"], region: ENV["AWS_SES_REGION"])
end
```


## Contributors

- [keizo3](https://github.com/keizo3) - creator, maintainer
