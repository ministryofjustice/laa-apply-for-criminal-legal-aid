class PostSubmissionApplicationPurger < ApplicationPurger
  class << self
    def call(crime_application)
      new(crime_application).call
    end
  end

  def initialize(crime_application)
    super(crime_application, nil)
  end
  private_class_method :new

  def call
    ActiveRecord::Base.transaction do
      delete_orphan_partner_assets!
      crime_application.destroy!
    end
  end
end
