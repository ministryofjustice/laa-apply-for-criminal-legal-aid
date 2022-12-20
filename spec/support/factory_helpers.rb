module FactoryHelpers
  TEST_OFFICE_CODE = '1A123B'.freeze

  def create_test_application(attributes = {})
    CrimeApplication.create(
      { office_code: TEST_OFFICE_CODE }.merge(attributes)
    )
  end
end
