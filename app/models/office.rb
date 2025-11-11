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
      Providers::GetActiveOffice.call(office_code)
    end
  end
end
