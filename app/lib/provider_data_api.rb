module ProviderDataApi
  module Types
    include Dry.Types()

    AreaOfLaw = String.enum(
      'MEDIATION',
      'LEGAL HELP',
      'CIVIL FUNDING',
      'CRIME LOWER'
    )
  end
end
