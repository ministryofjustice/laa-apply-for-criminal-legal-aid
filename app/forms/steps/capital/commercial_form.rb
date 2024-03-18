module Steps
  module Capital
    class CommercialForm < PropertyForm
      attribute :usage, :string

      validates :usage, presence: true
    end
  end
end
