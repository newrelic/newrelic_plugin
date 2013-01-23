module NewRelic

# Standard Errors
#
# Author:: Lee Atchison <lee@newrelic.com>
# Copyright:: Copyright (c) 2012 New Relic, Inc.
#
  module Plugin # :nodoc: 
    class AgentError<Exception;end
    class NoAgents<Exception;end
    class NoMetrics<Exception;end
    class NewRelicCommError<Exception;end
    class UnknownInstalledAgent<AgentError;end
    class UnknownInstalledProcessor<AgentError;end
    class CouldNotInitializeAgent<AgentError;end
    class CouldNotInitializeProcessor<AgentError;end
    class BadConfig<AgentError;end
    class NoResultReturned<AgentError;end
    class NoDataReturned<AgentError;end
    class InvalidMetricValueType<AgentError;end
  end
end
