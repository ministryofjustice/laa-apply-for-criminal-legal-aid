class Applicant < Person
  # Utility methods for testing/output
  delegate :partner_detail, to: :crime_application

  def has_partner # rubocop:disable Naming/PredicateName
    partner_detail&.has_partner
  end

  def relationship_status
    partner_detail&.relationship_status
  end

  def separation_date
    partner_detail&.separation_date
  end
end
