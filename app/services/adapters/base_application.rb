module Adapters
  class BaseApplication < SimpleDelegator
    delegate :in_progress?, :submitted?, :returned?, to: :status
    delegate :case_type, to: :case, allow_nil: true

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

    def status
      ApplicationStatus.new(super)
    end
  end
end
