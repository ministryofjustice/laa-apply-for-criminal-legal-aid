module Refinements
  module LocalizeWithTz
    DEFAULT_USER_TIME_ZONE = 'London'.freeze

    def self.included(base)
      base.class_eval { alias_method :l, :tz_l }
    end

    def tz_l(object, **)
      raise ArgumentError, 'Object must be a Date, DateTime or Time object.' unless object.respond_to?(:strftime)

      I18n.l(
        object.in_time_zone(DEFAULT_USER_TIME_ZONE), **
      )
    end
  end
end
