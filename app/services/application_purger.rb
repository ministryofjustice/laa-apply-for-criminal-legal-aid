class ApplicationPurger
  attr_reader :crime_application

  def self.call(crime_application)
    new(crime_application).call
  end

  def initialize(crime_application)
    @crime_application = crime_application
  end
  private_class_method :new

  def call
    delete_orphan_stored_documents
    crime_application.destroy!
  end

  private

  def delete_orphan_stored_documents
    orphan_documents.each do |document|
      Datastore::Documents::Delete.new(document:).call
    end
  end

  def orphan_documents
    crime_application.documents.stored.not_submitted
  end
end
