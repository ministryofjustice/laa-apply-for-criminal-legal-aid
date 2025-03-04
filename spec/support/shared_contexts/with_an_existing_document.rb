RSpec.shared_context 'with an existing document' do
  let(:crime_application) { CrimeApplication.new(usn: 123) }
  let(:file) { fixture_file_upload('uploads/test.pdf', 'application/pdf') }
  let(:content_type) { file.content_type }
  let(:declared_content_type) { file.content_type }
  let(:file_size) { file.tempfile.size }
  let(:filename) { file.original_filename }

  let(:attributes) do
    { crime_application:, content_type:, declared_content_type:, file_size:, filename: }
  end

  let(:document) do
    Document.new(attributes)
  end
end
