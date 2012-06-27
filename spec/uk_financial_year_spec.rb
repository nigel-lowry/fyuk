require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe UkFinancialYear do

  before :all do
    @fy = UkFinancialYear.from_s '2012/13'
  end

  subject { @fy }

  its(:first_day) { should == Date.parse('6 Apr 2012') }
  its(:last_day) { should == Date.parse('5 Apr 2013') }
  its(:next) { should == UkFinancialYear.from_s('2013/14') }
  its(:previous) { should == UkFinancialYear.from_s('2011/12') }
  its(:to_s) { should == '2012/13' }

  specify { UkFinancialYear.new(Date.parse '6 Apr 2011').should == UkFinancialYear.new(Date.parse '7 Apr 2011') }
  specify { UkFinancialYear.new(Date.parse '5 Apr 2011').should_not == UkFinancialYear.new(Date.parse '6 Apr 2011') }

  specify { UkFinancialYear.new(Date.parse '5 Apr 2011').should be < UkFinancialYear.new(Date.parse '6 Apr 2011') }

  specify { UkFinancialYear.new(Date.parse('7 Apr 2011')).to_s.should == '2011/12' }
  specify { UkFinancialYear.new(Date.parse('7 Apr 1999')).to_s.should == '1999/00' }

  describe "#first_day" do
    specify { UkFinancialYear.new(Date.parse '4 Apr 2011').first_day.should == Date.parse('6 Apr 2010') }
    specify { UkFinancialYear.new(Date.parse '5 Apr 2011').first_day.should == Date.parse('6 Apr 2010') }
    specify { UkFinancialYear.new(Date.parse '6 Apr 2011').first_day.should == Date.parse('6 Apr 2011') }
    specify { UkFinancialYear.new(Date.parse '7 Apr 2011').first_day.should == Date.parse('6 Apr 2011') }
  end

  describe "#last_day" do
    specify { UkFinancialYear.new(Date.parse '4 Apr 2011').last_day.should == Date.parse('5 Apr 2011') }
    specify { UkFinancialYear.new(Date.parse '5 Apr 2011').last_day.should == Date.parse('5 Apr 2011') }
    specify { UkFinancialYear.new(Date.parse '6 Apr 2011').last_day.should == Date.parse('5 Apr 2012') }
    specify { UkFinancialYear.new(Date.parse '7 Apr 2011').last_day.should == Date.parse('5 Apr 2012') }
  end

  describe "#.include?" do
    before :each do
      @fy = UkFinancialYear.from_s '2012/13'
    end

    subject { @fy }

    it { should_not include Date.parse '5 Apr 2012' }
    it { should include Date.parse '6 Apr 2012' }
    it { should include Date.parse '5 Apr 2013' }
    it { should_not include Date.parse '6 Apr 2013' } 
  end

  describe "#from_s" do
    specify { UkFinancialYear.from_s('1998/99').to_s.should == '1998/99' }
    specify { UkFinancialYear.from_s('1999/00').to_s.should == '1999/00' }
    specify { UkFinancialYear.from_s('2000/01').to_s.should == '2000/01' }

    it "raises error if years not consecutive" do
      expect {
        UkFinancialYear.from_s '2002/04'
      }.to raise_error(
        RuntimeError,
        /"2002" and "2004" are not consecutive years/
      ) 
    end

    it "raises error with wrong format" do
      expect {
        UkFinancialYear.from_s '20001/02'
      }.to raise_error(
        RuntimeError,
        /"20001\/02" does not match FY string format/
      ) 
    end
  end

  describe "#adjacent" do
    before :each do
      @fy2011_12 = UkFinancialYear.from_s '2011/12'
      @fy2012_13 = @fy2011_12.next
      @fy2013_14 = @fy2012_13.next
      @fy2013_15 = @fy2013_14.next
    end

    subject { @fy2012_13 }

    it { should be_adjacent @fy2011_12 }
    it { should be_adjacent @fy2013_14 }
    it { should_not be_adjacent @fy2013_15 }
    it { should_not be_adjacent @fy2012_13 }
  end

  describe "#before? and #after?" do
    before :each do
      @fy = UkFinancialYear.from_s '2011/12'
    end

    subject { @fy }

    it { should be_before UkFinancialYear.from_s('2012/13') }
    it { should be_after UkFinancialYear.from_s('2010/11') }
    it { should be_before UkFinancialYear.from_s('2012/13').last_day }
    it { should be_after UkFinancialYear.from_s('2010/11').first_day }
  end

  describe "creation without date" do
    it "is the current financial year" do
      Timecop.freeze(Date.parse '5 Jul 2010') do
        UkFinancialYear.new.should == UkFinancialYear.from_s('2010/11')
      end
    end
  end

  describe "#fy_before" do
    before :each do
      @fy = UkFinancialYear.from_s '2012/13'
    end

    subject { @fy }

    it "raises an error for a date before the FY" do
      expect {
        @fy.period_before(Date.parse '5 Apr 2012')
      }.to raise_error(
        RuntimeError,
        /2012-04-05 is before FY 2012\/13/
      )
    end

    it "raises an error for a date after the FY" do
      expect {
        @fy.period_before(Date.parse '6 Apr 2013')
      }.to raise_error(
        RuntimeError,
        /2013-04-06 is after FY 2012\/13/
      )
    end

    specify { @fy.period_before(Date.parse '6 Apr 2012').should == (Date.parse('6 Apr 2012')...Date.parse('6 Apr 2012')) }
    specify { @fy.period_before(Date.parse '7 Apr 2012').should == (Date.parse('6 Apr 2012')...Date.parse('7 Apr 2012')) }
    specify { @fy.period_before(Date.parse '8 Apr 2012').should == (Date.parse('6 Apr 2012')...Date.parse('8 Apr 2012')) }
  end
end