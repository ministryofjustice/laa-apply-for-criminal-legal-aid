RSpec.shared_context 'with an existing document' do
  let(:crime_application) { CrimeApplication.new(usn: 123) }
  let(:file) { fixture_file_upload('uploads/test.pdf', 'application/pdf') }
  let(:attributes) { { crime_application: } }

  let(:document) do
    Document.new(attributes)
  end
end
