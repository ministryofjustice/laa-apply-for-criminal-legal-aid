class DocumentBundle < ApplicationRecord
  belongs_to :crime_application
  has_many :documents, dependent: :destroy do
    def uploaded_to_s3
      select(&:uploaded_to_s3?)
    end
  end

  accepts_nested_attributes_for :documents, allow_destroy: true
end
