class UkFinancialYear
  include Comparable

  def initialize date
    start_date = start_date date
    @range = start_date...start_date.next_year
  end

  def UkFinancialYear.from_s s
    if /^20(?<year1>\d{2})\/(?<year2>\d{2})$/ =~ s
      year1 = 2000 + year1.to_i
      year2 = 2000 + year2.to_i
      raise %{"#{year1}" and "#{year2}" are not consecutive years} unless year1 + 1 == year2
      return new(Date.parse "6 Apr #{year1}")
    end

    raise %{"#{s}" does not match FY string format}
  end

  def first_day
    @range.min
  end

  def last_day
    @range.max
  end

  def include? date
    @range.include? date
  end

  def to_s
    "#{self.first_day.year}/#{self.last_day.year.to_s[-2..-1]}"
  end

  def ==(other)
    self.first_day == other.first_day
  end

  def <=>(other)
    self.first_day <=> other.first_day
  end

  private
    def start_date date
      swap_date_that_year = date.change day: 6, month: 4
      date >= swap_date_that_year ? swap_date_that_year : swap_date_that_year.prev_year
    end
end