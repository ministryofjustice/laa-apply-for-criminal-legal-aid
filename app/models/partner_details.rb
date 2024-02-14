class PartnerDetails < ApplicationRecord
  belongs_to :partner

  def has_contrary_interests?
    return true if YesNoAnswer.new(conflict_of_interest).yes?
    return true if victim_or_prosecution_witness?

    false
  end

  def involved_in_case?
    !InvolvementInCase.new(involvement_in_case).none?
  end

  def same_home_address_as_client?
    YesNoAnswer.new(same_home_address_as_client).yes?
  end

  private

  def victim_or_prosecution_witness?
    involvement = InvolvementInCase.new(involvement_in_case)
    involvement.victim? || involvement.prosecution_witness?
  end
end
