class CaseType < ValueObject
  VALUES = [
    SUMMARY_ONLY = new(:summary_only),
    EITHER_WAY = new(:either_way),
    INTICTABLE = new(:indictable),
    ALREADY_CC_TRIAL = new(:already_cc_trial),
    COMMITTAL = new(:committal),
    CC_APPEAL = new(:cc_appeal),
    CC_APPEAL_FIN_CHANGE = new(:cc_appeal_fin_change)
  ].freeze
end
