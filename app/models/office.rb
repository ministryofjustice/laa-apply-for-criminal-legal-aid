class Office
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Serialization

  attribute :office_code, :string
  attribute :name, :string
  attribute :active?, :boolean
  attribute :contingent_liability?, :boolean

  class << self
    def find(office_code)
      find!(office_code)
    rescue Errors::OfficeNotFound
      nil
    end

    def find!(office_code)
      return Providers::GetActiveOffice.call(office_code) if FeatureFlags.provider_data_api.enabled?

      # Static list offices are all non-Contingent Liability and active
      new(
        office_code: office_code,
        name: office_code,
        active?: true,
        contingent_liability?: false
      )
    end
  end
end
