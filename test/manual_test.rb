require 'test_helper'


new_relic_message = NewRelic::Plugin::NewRelicMessage.new('fake connection', 'manual curl test', 'manual-test-guid', 'version', 60)
new_relic_message.add_stat_fullname('test metric', 2, 2, :min => 1, :max => 3, :sum_of_squares => 10) 
new_relic_message.add_stat_fullname('other metric', 2, 2, :min => 2, :max => 2, :sum_of_squares => 8) 

puts <<-EOF
########################################################
Manual testing -- output curl command with payload
########################################################

 curl -vi http://collector.newrelic.com/platform/v1/metrics \
    -H "X-License-Key: ADD_LICENSE_KEY" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -X POST -d \'#{new_relic_message.send(:build_request_payload)}\'

########################################################
EOF
