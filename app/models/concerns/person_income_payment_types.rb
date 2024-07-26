module PersonIncomePaymentTypes
  extend ActiveSupport::Concern

  def partner_income_payments
    @partner_income_payments ||= income_payments.select do |payment|
      OwnershipType.new(payment.ownership_type).partner?
    end
  end

  def client_income_payments
    @client_income_payments ||= income_payments.select do |payment|
      OwnershipType.new(payment.ownership_type).applicant?
    end
  end

  def partner_income_benefits
    @partner_income_benefits ||= income_benefits.select do |benefit|
      OwnershipType.new(benefit.ownership_type).partner?
    end
  end

  def client_income_benefits
    @client_income_benefits ||= income_benefits.select do |benefit|
      OwnershipType.new(benefit.ownership_type).applicant?
    end
  end

  IncomePaymentType::VALUES.each do |payment_type|
    define_method(:"client_#{payment_type}_payment") do
      client_income_payments.find do |payment|
        IncomePaymentType.new(payment.payment_type) == payment_type
      end
    end

    define_method(:"partner_#{payment_type}_payment") do
      partner_income_payments.find do |payment|
        IncomePaymentType.new(payment.payment_type) == payment_type
      end
    end
  end
end
