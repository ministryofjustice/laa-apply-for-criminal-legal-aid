class ApplicationPurger
  attr_reader :crime_application, :log_context

  def self.call(crime_application, log_context)
    new(crime_application, log_context).call
  end

  def initialize(crime_application, log_context)
    @crime_application = crime_application
    @log_context = log_context
  end
  private_class_method :new

  def call
    ActiveRecord::Base.transaction do
      delete_orphan_stored_documents
      delete_orphan_partner_assets!
      crime_application.destroy!
    end
  end

  private

  def delete_orphan_stored_documents
    orphan_documents.each do |document|
      Datastore::Documents::Delete.new(document:, log_context:).call
    end
  end

  def delete_orphan_partner_assets!
    return if crime_application.partner.nil?
    return if MeansStatus.include_partner?(crime_application)

    partner_reflections.each do |ref|
      ref.constantize.where(
        crime_application: crime_application,
        ownership_type: OwnershipType::PARTNER.to_s
      ).delete_all
    end
  end

  def partner_reflections
    (Partner.reflections.keys - Person.reflections.keys).map(&:classify)
  end

  def orphan_documents
    crime_application.documents.stored.not_submitted
  end
end
