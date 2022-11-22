module Adapters
  class BaseApplication < SimpleDelegator
    def self.build(object)
      if object.respond_to?(:applicant)
        Adapters::DatabaseApplication
      else
        Adapters::JsonApplication
      end.new(object)
    end

    def to_param
      id
    end

    # Keep this wrapper method in case we retract from
    # using sequence USN to use any other ID/reference
    def laa_reference
      reference
    end
  end
end
