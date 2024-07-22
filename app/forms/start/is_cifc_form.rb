module Start
  class IsCifcForm < Steps::BaseFormObject
    attribute :is_cifc, :value_object, source: YesNoAnswer

    validates :is_cifc, inclusion: {
      in: :choices,
      message: I18n.t("#{to_s.underscore}.is_cifc.inclusion", scope: [:activemodel, :errors, :models])
    }

    def self.build(crime_application, is_cifc)
      form = new(crime_application:)
      form.is_cifc = is_cifc

      form
    end

    def choices
      [YesNoAnswer::NO, YesNoAnswer::YES]
    end

    private

    def persist!
      true
    end
  end
end
