class PropertyType < ValueObject
  VALUES = [
    RESIDENTIAL = new(:residential),
    COMMERCIAL = new(:commercial),
    LAND = new(:land)
  ].freeze

  def self.to_phrase(value)
    return '' if value.to_s.blank?

    I18n.t("helpers/dictionary.asset.#{value}")
  end

  def to_phrase
    I18n.t("helpers/dictionary.asset.#{self}")
  end
end
