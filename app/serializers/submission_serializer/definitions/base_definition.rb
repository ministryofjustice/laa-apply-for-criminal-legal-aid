require 'jbuilder'

module SubmissionSerializer
  module Definitions
    class BaseDefinition < SimpleDelegator
      def self.generate(object)
        new(object).generate
      end

      def generate
        return unless __getobj__

        to_builder.attributes!
      end

      # :nocov:
      def to_builder
        raise 'must be implemented in subclasses'
      end
      # :nocov:
    end
  end
end
