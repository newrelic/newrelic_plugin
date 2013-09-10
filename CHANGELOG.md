## New Relic Ruby SDK Change Log ##

### vNext - Future Date ###

**Features**


### v1.2.1 - September 10, 2013 ###

**Bug Fixes**

* Send agent version to the HTTP API, not the SDK version.
* Stop using SSL by default in Ruby versions below 1.9 (this fixes an issue where the agent stops reporting)
* Set timeouts on HTTP API connection (fixes an issue where the agent stops reporting in Ruby 1.9 and higher)


### v1.2.0 - August 19, 2013 ###

**Features**

* Aggregate data when the collector is unreachable.

**Bug Fixes**

* Fixed issue where the ssl_host_verification flag was not working.
* Fixed ordering of min and max in metric array that is sent to the HTTP API.


### v1.1.1 - August 13, 2013 ###

**Bug Fixes**

* Fixed issue where to_set method was not found when requiring this gem without using bundler.
* Added JSON as a dependency to provide Ruby 1.8.7 support.

### v1.1.0 - August 5, 2013 ###

**Features**

* Improved logging
* Support for proxies

**Bug Fixes**

* Duration of data collection time is now calculated to match actual duration

**Changes**

* Dropped dependency on Faraday

### v1.0.3 - June 25, 2013 ###

**Features**

* Added timestamps to output to improve debugging experience.

### v1.0.2 - June 19, 2013 ###

**Features**

* Released on [RubyGems](http://rubygems.org/gems/newrelic_plugin)

### v1.0.1 - June 18, 2013 ###

**Features**

* Added configuration option for SSL hostname verification

### v1.0.0 - June 14, 2013 ###

**Features**

* Initial public release version of the New Relic Platform Ruby SDK

