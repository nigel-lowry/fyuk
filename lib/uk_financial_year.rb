require 'active_support/all'

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
    "#{first_day.year}/#{last_day.year.to_s.from 2}"
  end

  # creates a new UkFinancialYear from a string in the form '2000/01'
  # @param [String] s the two years of the financial year in the form
  # of the first year as four digits, a '/', then the last year as
  # two digits
  # @raise [RuntimeError] if the string cannot be parsed to a financial year
  # @return [UkFinancialYear] the financial year specified by the string
  def UkFinancialYear.from_s s
    check_format s
    new(Date.new s.to(3).to_i, 4, 6)
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
    other_financial_year.last_day.tomorrow == self.first_day or other_financial_year.first_day.yesterday == self.last_day
  end

  # tells if the given date or financial year is before this one
  # @param [Date] date_or_fy date or financial year to check
  # @return [Boolean] to indicate if this financial year is before
  def before? date_or_fy
    self.first_day < date_to_compare(date_or_fy)
  end

  # tells if the given date or financial year is after this one
  # @param (see UkFinancialYear#before?)
  # @return [Boolean] to indicate if this financial year is after
  def after? date_or_fy
    self.first_day > date_to_compare(date_or_fy)
  end

  # returns the period before this date in the financial year
  # @param [Date] date a date in the financial year
  # @return [Range<Date>] the period before this date in the the
  # financial year 
  def period_before date
    raise "#{date} is before FY #{to_s} which starts on #{first_day}" if date < first_day
    raise "#{date} is after FY #{to_s} which ends on #{last_day}" if date > last_day

    first_day...date
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
      swap_date_that_year = date.change day: 6, month: 4
      date < swap_date_that_year ? swap_date_that_year.prev_year : swap_date_that_year
    end

    def self.check_format s
      if /^(?<year1>\d{4})\/(?<year2>\d{2})$/ =~ s
        year1 = year1.to_i
        year1_century = year1 / 100
        year2_century = year1 % 100 == 99 ? year1_century + 1 : year1_century
        year2 = year2_century * 100 + year2.to_i
        raise %{"#{year1}" and "#{year2}" are not consecutive years} unless year1 + 1 == year2
      else
        raise %{"#{s}" does not match FY string format}
      end
    end

    def date_to_compare other
      other.is_a?(Date) ? other : other.first_day
    end

end