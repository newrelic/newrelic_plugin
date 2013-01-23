module NewRelic
  module Plugin
    module Processor
#
#
# Processor Base Class
#
#
      class Base
        attr_reader :ident,:label
        def initialize ident,label
          @ident=ident
          @label=label
        end
      end
    end
  end
end
