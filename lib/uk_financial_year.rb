require 'date'

# Makes working with the UK financial or fiscal year easier.
class UkFinancialYear
  include Comparable

  # creates a new UkFinancialYear as the financial year which
  # includes the given date
  # @param [Date] date the date to create a financial year for. 
  # If missing returns the current financial year
  # @return [UkFinancialYear] the financial year which covers the date
  def initialize date=Date.today
    start_date = start_date date
    @range = start_date...start_date.next_year
  end

  # returns string representation of the financial year in the form '2000/01'.
  # This is the form HMRC use.
  # @return [String] representation in the form of the first year as four
  # digits, a '/', then the last year as two digits
  def to_s
    "#{self.first_day.year}/#{self.last_day.year.to_s.last(2)}"
  end

  # creates a new UkFinancialYear from a string in the form '2000/01'
  # @param [String] s the two years of the financial year in the form
  # of the first year as four digits, a '/', then the last year as
  # two digits
  # @raise [RuntimeError] if the string cannot be parsed to a financial year
  # @return [UkFinancialYear] the financial year specified by the string
  def UkFinancialYear.from_s s
    if /^(?<year1>\d{4})\/(?<year2>\d{2})$/ =~ s
      year1 = year1.to_i
      year1_century = year1 / 100
      year2_century = year1 % 100 == 99 ? year1_century + 1 : year1_century
      year2 = year2_century * 100 + year2.to_i
      raise %{"#{year1}" and "#{year2}" are not consecutive years} unless year2 == year1 + 1
      return new(Date.new year1, 4, 6)
    end

    raise %{"#{s}" does not match FY string format}
  end

  # returns the date of the first day of the financial year
  # @return [Date] the first day
  def first_day
    @range.min
  end

  # returns the date of the last day of the financial year
  # @return [Date] the last day
  def last_day
    @range.max
  end

  # tells if the financial year includes the given date
  # @param [Date] date the date to check
  # @return [Boolean] to indicate if the date is within the financial year
  def include? date
    @range.include? date
  end

  # returns the next financial year
  # @return [UkFinancialYear] the next financial year
  def next
    UkFinancialYear.new self.first_day.next_year
  end

  # returns the previous financial year
  # @return [UkFinancialYear] the previous financial year
  def previous
    UkFinancialYear.new self.first_day.prev_year
  end

  def adjacent? other_financial_year
    self.first_day.next_year == other_financial_year.first_day or self.first_day.prev_year == other_financial_year.first_day
  end

  def before? other
    self.first_day.before?(other.first_day)
  end

  def after? other
    self.first_day.after?(other.first_day)
  end

  # equality method
  def == other
    self.first_day == other.first_day
  end

  # lesser financial years are those which occur earliest
  def <=> other
    self.first_day <=> other.first_day
  end

  private
    def start_date date
      swap_date_that_year = Date.new date.year, 4, 6
      date.after?(swap_date_that_year) ? swap_date_that_year : swap_date_that_year.prev_year
    end
end

class String
  def last n
    self[-n, n]
  end
end

class Date
  def before? other
    self < other
  end

  def after? other
    self >= other # FIXME this is wrong
  end
end