class Court
  def initialize(name:)
    @name = name
  end

  attr_reader :name

  class << self
    # TODO: we still need to confirm which courts to list.
    #
    # In the meantime use the CourtCentre csv from hmcts_common_platform gem
    # and filters by oucode_l1_code to produce a list of magistrates' and crown courts.
    #
    def all
      @all ||= begin
        oucode_l1_code = %w[B C]

        rows = HmctsCommonPlatform::Reference::CourtCentre.csv.select do |cc|
          oucode_l1_code.include? cc['oucode_l1_code']
        end

        rows.map { |r| new(name: r['oucode_l3_name']) }
            .sort_by(&:name)
      end
    end
  end
end
