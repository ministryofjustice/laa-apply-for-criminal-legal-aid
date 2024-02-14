class Partner < Person
  has_one :partner_details, dependent: :destroy

  delegate :has_contrary_interests?, :same_home_address_as_client?, to: :partner_details
end
