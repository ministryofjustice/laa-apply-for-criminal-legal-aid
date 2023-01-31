module FactoryHelpers
  TEST_OFFICE_CODE = '1A123B'.freeze

  def create_test_application(attributes = {})
    CrimeApplication.create(
      { office_code: TEST_OFFICE_CODE }.merge(attributes)
    )
  end

  def build_struct_application(fixture_name: 'application')
    Adapters::Structs::CrimeApplication.new(
      JSON.parse(LaaCrimeSchemas.fixture(1.0, name: fixture_name).read)
    )
  end
end
