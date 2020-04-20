[![Archived header](https://github.com/newrelic/open-source-office/raw/master/examples/categories/images/Archived.png)](https://github.com/newrelic/open-source-office/blob/master/examples/categories/index.md#archived)

# New Relic Platform Agent SDK

## Requirements

 * Tested with Ruby 1.8.7, 1.9.3, 2.0.0
 
**Note:** In Ruby 1.8.7 SSL is disabled by default due to issues with how Net::HTTP handles connection timeouts.

If you override this the plugin may occasionally stop reporting data and require a restart.
To override you can add the following to `newrelic:` section of the newrelic_config.yml. 

```
 endpoint: 'https://platform-api.newrelic.com'
```


## Get Started

This repo represents the core Ruby gem used to build plugin agents for
the New Relic platform. If you are looking to build or use a platform
component, please refer to the
[getting started documentation](https://docs.newrelic.com/docs/plugins/developing-plugins).

Install this gem by running `gem install newrelic_plugin` or add it to your
[bundler](http://gembundler.com/) Gemfile like this:

```ruby
gem "newrelic_plugin"
```

Alternatively you can build and install the gem locally:

```bash
git clone git@github.com:newrelic-platform/newrelic_plugin.git
cd newrelic_plugin
rake build
gem install pkg/newrelic_plugin*
```

## Configuration

All configuration is done through the `newrelic_plugin.yml` file within the `config` directory of a plugin.

### New Relic License Key

The New Relic license key can be configured through the `newrelic_plugin.yml` file, or through an environment variable.

#### Config file

```
newrelic:
  #
  # Update with your New Relic account license key:
  #
  license_key: 'YOUR_LICENSE_KEY_HERE'
```

#### Environment variable

When running a plugin, pass the environment variable `NEWRELIC_LICENSE_KEY`.
```
NEWRELIC_LICENSE_KEY=YOUR_LICENSE_KEY_HERE ./<plugin_bin>
```
**Note:** Be sure to comment out the license_key in the `newrelic_plugin.yml` file when using the environment variable.

### Proxy Settings

To configure the proxy settings, edit the `newrelic_plugin.yml` file and add to the `newrelic` section:

```
newrelic:
  proxy:
    address: PROXY_ADDRESS
    port: PROXY_PORT
    user: PROXY_USER
    password: PROXY_PASSWORD
```

## Support

Reach out to us at
[support.newrelic.com](http://support.newrelic.com/).
There you'll find documentation, FAQs, and forums where you can submit
suggestions and discuss with staff and other users.

Also available is [community support on Stack Overflow](http://stackoverflow.com/questions/tagged/newrelic-platform).

Find a bug? E-mail <support@newrelic.com>, or submit a ticket to

[support.newrelic.com](http://support.newrelic.com/).

Thank you!
