class OffenceSynonyms
  include Singleton

  attr_reader :config

  def initialize
    @config = YAML.load_file(
      Rails.root.join('config/data/offence_synonyms.yml'), permitted_classes: [Regexp]
    ).fetch('offence_synonyms', []).freeze
  end

  class << self
    delegate :lookup, to: :instance
  end

  def lookup(name)
    config.select { |cfg| name =~ cfg['regex'] }.pluck('synonyms').flatten.uniq
  end
end
