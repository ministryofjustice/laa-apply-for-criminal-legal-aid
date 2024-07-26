module Evidence
  module RuleDsl
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      DEFAULT_PREDICATE = ->(_crime_application) { false }
      DEFAULT_KEY = :UNKNOWN_KEY
      DEFAULT_GROUP = :none

      def key(value = nil)
        if value.nil?
          @key ||= DEFAULT_KEY
        else
          @key = value
        end
      end

      def group(value = nil)
        if value.nil?
          @group ||= DEFAULT_GROUP
        else
          @group = value
        end
      end

      def archived(value = nil)
        if value.nil?
          @archived ||= false
        else
          @archived = value
        end
      end

      def client(&block)
        @client_proc = block
      end

      def partner(&block)
        @partner_proc = block
      end

      def other(&block)
        @other_proc = block
      end

      def execute_client(crime_application)
        if @client_proc.respond_to?(:call)
          @client_proc.call(crime_application)
        else
          DEFAULT_PREDICATE.call(crime_application)
        end
      end

      def execute_partner(crime_application)
        if @partner_proc.respond_to?(:call)
          @partner_proc.call(crime_application)
        else
          DEFAULT_PREDICATE.call(crime_application)
        end
      end

      def execute_other(crime_application)
        if @other_proc.respond_to?(:call)
          @other_proc.call(crime_application)
        else
          DEFAULT_PREDICATE.call(crime_application)
        end
      end
    end
  end
end
