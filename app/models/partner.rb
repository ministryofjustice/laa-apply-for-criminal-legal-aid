class Partner < Person
  has_one :partner_details, dependent: :destroy

  delegate :has_contrary_interests?, to: :partner_details
end
