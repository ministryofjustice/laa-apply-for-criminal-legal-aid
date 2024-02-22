module Payable
  extend ActiveSupport::Concern

  included do
    def self.build_with_pennies(options)
      attrs = options.dup
      attrs[:amount] = (options[:amount].to_f / 100) if options[:amount].present?

      new(**attrs)
    end
  end
end
