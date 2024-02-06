class PartnerDetails < ApplicationRecord
  belongs_to :partner

  def has_contrary_interests?
    return true if conflict_of_interest == YesNoAnswer::YES
    return true if victim_or_prosecution_witness?

    false
  end

  def involved_in_case?
    return false if involvement_in_case != InvolvementInCase::NONE

    true
  end

  private

  def victim_or_prosecution_witness?
    [InvolvementInCase::VICTIM, InvolvementInCase::PROSECUTION_WITNESS].include?(
      InvolvementInCase.new(involvement_in_case)
    )
  end
end
