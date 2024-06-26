require 'jbuilder'

module SubmissionSerializer
  module Definitions
    class BaseDefinition < SimpleDelegator
      def self.generate(object)
        new(object).generate
      end

      def generate
        if respond_to?(:map)
          filter_map { |item| self.class.generate(item) }
        elsif present?
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
