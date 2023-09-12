RSpec.shared_context 'with an existing document' do
  let(:bundle) { DocumentBundle.create(crime_application: CrimeApplication.new(usn: 123)) }
  let(:file) { fixture_file_upload('uploads/test.pdf', 'application/pdf') }
  let(:attributes) { { document_bundle: bundle } }

  let(:document) do
    Document.new(attributes)
  end

  # before :all do
    # app = CrimeApplication.create
    # bundle = DocumentBundle.create(crime_application: app)
    # file = fixture_file_upload('uploads/test.pdf', 'application/pdf')
    #
    # # Successfully uploaded document
    # Document.create_from_file(file:, bundle:).update(
    #   s3_object_key: '123/abcdef1234'
    # )
    #
    # too_big_err_file = Document.create_from_file(file:, bundle:)
    # too_big_err_file.update(
    #   filename: 'too_big.pdf',
    #   file_size: 210_000_00 # 21 MB
    # )
    #
    # too_small_err_file = Document.create_from_file(file:, bundle:)
    # too_small_err_file.update(
    #   filename: 'too_small.pdf',
    #   file_size: 2 # 2 KB
    # )
    #
    # content_type_err_file = Document.create_from_file(file:, bundle:)
    # content_type_err_file.update(
    #   filename: 'invalid_content_type.pdf',
    #   content_type: 'video/mp4'
    # )
    #
    # # # To generate error message
    # too_big_err_file.valid?(:criteria)
    # too_small_err_file.valid?(:criteria)
    # content_type_err_file.valid?(:criteria)
    #
    # # Unsuccessful upload for any other reason (no s3 key)
    # Document.create_from_file(file:, bundle:).update(
    #   filename: 'error.pdf'
    # )
  # end
end
