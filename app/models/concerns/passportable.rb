module Passportable
  extend ActiveSupport::Concern

  delegate :age_passported?,
           :benefit_check_passported?, to: :means_passporter

  def means_passported?
    means_passporter.passported?
  end

  def ioj_passported?
    ioj_passporter.passported?
  end

  private

  def means_passporter
    Passporting::MeansPassporter.new(self)
  end

  def ioj_passporter
    Passporting::IojPassporter.new(self)
  end
end
