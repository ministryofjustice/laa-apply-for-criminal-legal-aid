class OutgoingsPayment < Payment
  store_accessor :metadata,
                 :details,
                 :case_reference,
                 :board_amount,
                 :food_amount,
                 :payee_name,
                 :payee_relationship_to_client

  # TODO: Not sure why scope does not work instead
  def self.mortgage
    where(payment_type: OutgoingsPaymentType::MORTGAGE.value).order(created_at: :desc).first
  end

  def self.rent
    where(payment_type: OutgoingsPaymentType::RENT.value).order(created_at: :desc).first
  end

  def self.board_and_lodging
    where(payment_type: OutgoingsPaymentType::BOARD_AND_LODGING.value).order(created_at: :desc).first
  end

  def self.council_tax
    where(payment_type: OutgoingsPaymentType::COUNCIL_TAX.value).order(created_at: :desc).first
  end

  def self.housing_payments
    where(payment_type: OutgoingsPaymentType::HOUSING_PAYMENT_TYPES.map(&:to_s))
  end

  # Manually cast food_amount and board_amount
  # because Rails will not convert to :pence as they are
  # store_accessor attributes
  def food_amount=(value)
    super(Type::Pence.new.serialize(value))
  end

  def food_amount
    Type::Pence.new.deserialize(super)
  end

  def board_amount=(value)
    super(Type::Pence.new.serialize(value))
  end

  def board_amount
    Type::Pence.new.deserialize(super)
  end
end
