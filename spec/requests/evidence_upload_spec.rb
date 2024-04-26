require 'rails_helper'

RSpec.describe 'Evidence upload page', :authorized do
  before :all do
    crime_application = CrimeApplication.create
    file = fixture_file_upload('uploads/test.pdf', 'application/pdf')

    # Successfully uploaded document
    Document.create_from_file(file:, crime_application:).update(
      s3_object_key: '123/abcdef1234'
    )

    too_big_err_file = Document.create_from_file(file:, crime_application:)
    too_big_err_file.update(
      filename: 'too_big.pdf',
      file_size: 11.megabytes
    )

    too_small_err_file = Document.create_from_file(file:, crime_application:)
    too_small_err_file.update(
      filename: 'too_small.pdf',
      file_size: 2.kilobytes
    )

    content_type_err_file = Document.create_from_file(file:, crime_application:)
    content_type_err_file.update(
      filename: 'invalid_content_type.pdf',
      content_type: 'video/mp4'
    )

    # To generate error messages
    too_big_err_file.valid?(:criteria)
    too_small_err_file.valid?(:criteria)
    content_type_err_file.valid?(:criteria)

    # Unsuccessful upload for any other reason (no s3 key)
    Document.create_from_file(file:, crime_application:).update(
      filename: 'error.pdf'
    )
  end

  after :all do
    CrimeApplication.destroy_all
  end

  describe 'list of uploaded documents' do
    let(:crime_application) { CrimeApplication.first }

    before do
      get edit_steps_evidence_upload_path(crime_application)
    end

    it 'lists the uploaded documents with their details' do
      expect(response).to have_http_status(:success)

      assert_select 'h1', 'Upload supporting evidence'

      assert_select 'tbody.govuk-table__body' do
        assert_select 'tr.govuk-table__row:nth-of-type(1)' do
          assert_select 'span._uploaded_file__filename', 'test.pdf'
          assert_select 'strong.govuk-tag:nth-of-type(1)', 'Uploaded'
        end
      end
    end

    context 'when there are errors with upload' do
      it 'lists file size error messages' do
        assert_select 'tbody.govuk-table__body' do
          assert_select 'tr.govuk-table__row:nth-of-type(2)' do
            assert_select 'span:nth-of-type(1)', 'too_big.pdf'
            assert_select 'p:nth-of-type(1)',
                          "Error: #{I18n.t('activerecord.errors.models.document.attributes.file_size.too_big',
                                           max_size: FileUploadValidator::MAX_FILE_SIZE)}"
          end
          assert_select 'tr.govuk-table__row:nth-of-type(3)' do
            assert_select 'span:nth-of-type(1)', 'too_small.pdf'
            assert_select 'p:nth-of-type(1)',
                          "Error: #{I18n.t('activerecord.errors.models.document.attributes.file_size.too_small',
                                           min_size: FileUploadValidator::MIN_FILE_SIZE)}"
          end
        end
      end

      it 'lists content type error message' do
        assert_select 'tr.govuk-table__row:nth-of-type(4)' do
          assert_select 'span:nth-of-type(1)', 'invalid_content_type.pdf'
          assert_select 'p:nth-of-type(1)',
                        "Error: #{I18n.t('activerecord.errors.models.document.attributes.content_type.invalid')}"
        end
      end

      it 'lists generic error message' do
        assert_select 'tr.govuk-table__row:nth-of-type(5)' do
          assert_select 'span:nth-of-type(1)', 'error.pdf'
          assert_select 'p:nth-of-type(1)',
                        "Error: #{I18n.t('activerecord.errors.models.document.attributes.s3_object_key.blank')}"
        end
      end
    end
  end
end
