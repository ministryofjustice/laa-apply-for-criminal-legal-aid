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
      crime_application.destroy!
    end
  end

  private

  def delete_orphan_stored_documents
    orphan_documents.each do |document|
      Datastore::Documents::Delete.new(document:, log_context:).call
    end
  end

  def orphan_documents
    crime_application.documents.stored.not_submitted
  end
end
