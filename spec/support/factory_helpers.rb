module FactoryHelpers
  TEST_OFFICE_CODE = '1A123B'.freeze

  def create_test_application(attributes = {})
    CrimeApplication.create(
      { office_code: TEST_OFFICE_CODE }.merge(attributes)
    )
  end

  def build_struct_application(fixture_name: 'application', with_full_means: false)
    app = JSON.parse(LaaCrimeSchemas.fixture(1.0, name: fixture_name).read)

    if with_full_means
      app = app.deep_merge('means_details' => JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'means').read))
    end

    Adapters::JsonApplication.new(app)
  end
end
