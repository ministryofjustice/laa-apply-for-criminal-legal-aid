class Integer
  def ordinalize_fully
    I18n.t("integer.ordinalize_fully.#{self}")
  end
end
