class OutgoingsPaymentsValidator < BasePaymentsValidator
  def has_no_payments?
    record.has_no_other_outgoings.blank?
  end
end
