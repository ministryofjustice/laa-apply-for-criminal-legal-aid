class CaseType < ValueObject
  VALUES = [
    SUMMARY_ONLY = new(:summary_only),
    EITHER_WAY = new(:either_way),
    INDICTABLE = new(:indictable),
    ALREADY_CC_TRIAL = new(:already_cc_trial),
    COMMITTAL = new(:committal),
    CC_APPEAL = new(:cc_appeal),
    CC_APPEAL_FIN_CHANGE = new(:cc_appeal_fin_change)
  ].freeze

  DATE_STAMPABLE = [
    SUMMARY_ONLY,
    EITHER_WAY,
    COMMITTAL,
    CC_APPEAL,
  ].freeze

  def date_stampable?
    DATE_STAMPABLE.include?(self)
  end
end
