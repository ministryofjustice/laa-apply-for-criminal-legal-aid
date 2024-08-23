class PartnerIncomeBenefitsValidator < ActiveModel::Validator
  attr_reader :record

  def validate(record)
    @record = record

    record.types.each_with_index do |type, index|
      next if type == 'none'

      income_benefit = record.public_send(type)
      add_indexed_errors(income_benefit, index) unless income_benefit.valid?
    end

    return unless record.types.empty?

    record.errors.add(:base, :none_selected) if record.partner_has_no_income_benefits.blank?
  end

  private

  def add_indexed_errors(income_benefit, index)
    income_benefit.errors.each do |error|
      attr_name = indexed_attribute(index, income_benefit, error.attribute)

      record.errors.add(
        attr_name,
        error.type,
        message: error_message(income_benefit, error)
      )

      # We define the attribute getter as it doesn't really exist
      record.define_singleton_method(attr_name) do
        income_benefit.public_send(error.attribute)
      end
    end
  end

  def indexed_attribute(_index, income_benefit, attr)
    "#{income_benefit.payment_type.dasherize}-#{attr}"
  end

  # `activemodel.errors.models.steps/income/partner/income_benefit_fieldset_form.summary.x.y`
  def error_message(obj, error)
    payment_type = I18n.t(
      obj.payment_type,
      scope: [:helpers, :label, :steps_income_income_benefits_form, :types_options]
    )
    payment_type&.downcase! if obj.payment_type == IncomeBenefitType::OTHER.to_s

    I18n.t(
      "#{obj.model_name.i18n_key}.summary.#{error.attribute}.#{error.type}",
      scope: [:activemodel, :errors, :models],
      payment_type: payment_type
    )
  end
end
