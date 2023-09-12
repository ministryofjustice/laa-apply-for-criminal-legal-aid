require 'rails_helper'

RSpec.describe 'Evidence upload page', authorized: true do
  # include_context 'with an existing document'

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
          assert_select 'span:nth-of-type(1)', 'test.pdf'
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
                                           max_size: 20)}"
          end
          assert_select 'tr.govuk-table__row:nth-of-type(3)' do
            assert_select 'span:nth-of-type(1)', 'too_small.pdf'
            assert_select 'p:nth-of-type(1)',
                          "Error: #{I18n.t('activerecord.errors.models.document.attributes.file_size.too_small',
                                           min_size: 5)}"
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
