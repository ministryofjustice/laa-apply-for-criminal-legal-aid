module Adapters
  class BaseApplication < SimpleDelegator
    # NOTE: eventually it will be best not to rely on any delegation
    # and declare explicitly all the attributes and where they come from
    # in each adapter. Leaving this for now tho.
    #
    delegate :first_name, :last_name, :date_of_birth, to: :applicant
    delegate :case_type, to: :case, allow_nil: true

    def self.build(object)
      if object.respond_to?(:applicant)
        Adapters::DatabaseApplication
      else
        Adapters::JsonApplication
      end.new(object)
    end

    def to_param
      self['id']
    end

    # Keep this wrapper method in case we retract from
    # using sequence USN to use any other ID/reference
    def laa_reference
      self['reference']
    end
  end
end
