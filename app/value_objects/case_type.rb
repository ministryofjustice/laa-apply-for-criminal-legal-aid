class CaseType < ValueObject
  VALUES = [
    SUMMARY_ONLY = new(:summary_only),
    EITHER_WAY = new(:either_way),
    INDICTABLE = new(:indictable),
    ALREADY_IN_CROWN_COURT = new(:already_in_crown_court),
    COMMITTAL = new(:committal),
    APPEAL_TO_CROWN_COURT = new(:appeal_to_crown_court),
    APPEAL_TO_CROWN_COURT_WITH_CHANGES = new(:appeal_to_crown_court_with_changes),
  ].freeze

  DATE_STAMPABLE = [
    SUMMARY_ONLY,
    EITHER_WAY,
    COMMITTAL,
    APPEAL_TO_CROWN_COURT,
    APPEAL_TO_CROWN_COURT_WITH_CHANGES,
  ].freeze

  def date_stampable?
    DATE_STAMPABLE.include?(self)
  end
end
