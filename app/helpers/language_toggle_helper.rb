module LanguageToggleHelper
  def language_toggle_allowed?
    FeatureFlags.welsh_translation.enabled?
  end
end
