RSpec.shared_context 'with stubbed search results' do
  let(:datastore_api_endpoint) { 'http://datastore-webmock/api/v1/searches' }
  let(:stubbed_search_results) do
    [
      ApplicationSearchResult.new(
        applicant_name: 'Kit Pound',
        resource_id: '696dd4fd-b619-4637-ab42-a5f4565bcf4a',
        reference: 120_398_120,
        status: 'submitted',
        review_status: 'assessment_completed',
        submitted_at: '2022-10-27T14:09:11.000+00:00',
        application_type: 'initial',
      ),
      ApplicationSearchResult.new(
        applicant_name: 'Don JONES',
        resource_id: '1aa4c689-6fb5-47ff-9567-5eee7f8ac2cc',
        reference: 1_230_234_359,
        status: 'submitted',
        review_status: 'assessment_completed',
        submitted_at: '2022-11-11T16:58:15.000+00:00',
        application_type: 'post_submission_evidence',
      )
    ]
  end

  let(:datastore_response) do
    pagination = Pagination.new(
      total_count: stubbed_search_results.size,
      total_pages: 2,
      limit_value: 50
    ).attributes

    records = stubbed_search_results.map(&:attributes)

    { pagination:, records: }.deep_stringify_keys
  end

  before do
    stub_request(:post, datastore_api_endpoint)
      .to_return(body: datastore_response.to_json)
  end
end
