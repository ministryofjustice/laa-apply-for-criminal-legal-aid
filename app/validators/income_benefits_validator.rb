class IncomeBenefitsValidator < ActiveModel::Validator
  attr_reader :record

  def validate(record)
    @record = record

    record.types.each do |type|
      next if type == 'none'

      income_benefit = record.public_send(type)
      add_errors(income_benefit) unless income_benefit.valid?
    end

    return unless record.types.empty?

    record.errors.add(:base, :none_selected) if record.has_no_income_benefits.blank?
  end

  private

  def add_errors(income_benefit)
    income_benefit.errors.each do |error|
      attr_name = "#{income_benefit.payment_type.dasherize}-#{error.attribute}"
      record.errors.add(attr_name, error.type, message: error.message)

      # We define the attribute getter as it doesn't really exist
      record.define_singleton_method(attr_name) do
        income_benefit.public_send(error.attribute)
      end
    end
  end
end
