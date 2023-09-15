RSpec.shared_context 'with an existing document' do
  let(:bundle) { DocumentBundle.create(crime_application: CrimeApplication.new(usn: 123)) }
  let(:file) { fixture_file_upload('uploads/test.pdf', 'application/pdf') }
  let(:attributes) { { document_bundle: bundle } }

  let(:document) do
    Document.new(attributes)
  end
end
