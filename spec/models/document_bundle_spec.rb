require 'rails_helper'

RSpec.describe DocumentBundle, type: :model do
  subject { described_class.new(attributes) }

  describe '`documents` relationship' do
    subject(:documents) do
      described_class.create(
        crime_application:
      ).documents
    end

    let(:crime_application) { CrimeApplication.create }

    it 'has an association extension to return documents uploaded to s3 only' do
      documents << Document.new
      expect(documents.uploaded_to_s3).to be_empty
      documents << Document.new(s3_object_key: '123/abcdef1234')
      expect(documents.uploaded_to_s3).not_to be_empty
    end
  end
end
