require 'jbuilder'

module SubmissionSerializer
  module Definitions
    class BaseDefinition < SimpleDelegator
      def self.generate(object)
        new(object).generate
      end

      def generate
        return if blank?

        if respond_to?(:map)
          map { |item| self.class.generate(item) }
        else
          to_builder.attributes!
        end
      end

      # :nocov:
      def to_builder
        raise 'must be implemented in subclasses'
      end
      # :nocov:
    end
  end
end
