require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe UkFinancialYear do
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

  describe "equality" do
    it "is the same for values falling in the same FY" do
      fy1 = UkFinancialYear.new(Date.parse '6 Apr 2011')
      fy2 = UkFinancialYear.new(Date.parse '7 Apr 2011')
      fy1.should == fy2
    end

    it "is different for values in different FYs" do
      fy1 = UkFinancialYear.new(Date.parse '5 Apr 2011')
      fy2 = UkFinancialYear.new(Date.parse '6 Apr 2011')
      fy1.should_not == fy2
    end   
  end
  
  describe "#to_s" do
    specify { UkFinancialYear.new(Date.parse('7 Apr 2011')).to_s.should == '2011/12' }
    specify { UkFinancialYear.new(Date.parse('7 Apr 1999')).to_s.should == '1999/00' }
  end

  describe "#from_s" do
    it "is 2010/11 for '2010/11'" do
      fy = UkFinancialYear.from_s '2010/11'
      fy.first_day.should == Date.parse('6 Apr 2010')
      fy.last_day.should == Date.parse('5 Apr 2011')
    end

    it "is 2002/03 for '2002/03'" do
      fy = UkFinancialYear.from_s '2002/03'
      fy.first_day.should == Date.parse('6 Apr 2002')
      fy.last_day.should == Date.parse('5 Apr 2003')
    end

    it "is 1998/99 for '1998/99'" do
      fy = UkFinancialYear.from_s '1998/99'
      fy.first_day.should == Date.parse('6 Apr 1998')
      fy.last_day.should == Date.parse('5 Apr 1999')
    end

    it "is 1999/00 for '1999/00'" do
      fy = UkFinancialYear.from_s '1999/00'
      fy.first_day.should == Date.parse('6 Apr 1999')
      fy.last_day.should == Date.parse('5 Apr 2000')
    end

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

  describe "#next" do
    specify { UkFinancialYear.from_s('2011/12').next.should == UkFinancialYear.from_s('2012/13') }
  end 

  describe "#previous" do
    it "returns the previous financial year" do
      fy = UkFinancialYear.from_s '2011/12'
      fy.previous.should == UkFinancialYear.from_s('2010/11')
    end
  end 

  describe "#adjacent" do
    it "is true for two consecutive financial years in date order" do
      fy1 = UkFinancialYear.from_s '2011/12'
      fy2 = UkFinancialYear.from_s '2012/13'

      fy1.should be_adjacent fy2
      fy2.should be_adjacent fy1
    end

    it "is false for financial years which do not run together" do
      fy1 = UkFinancialYear.from_s '2011/12'
      fy2 = UkFinancialYear.from_s '2013/14'

      fy1.should_not be_adjacent fy2
      fy2.should_not be_adjacent fy1
    end

    it "is false for the same financial year" do
      fy1 = UkFinancialYear.from_s '2011/12'
      fy2 = UkFinancialYear.from_s '2011/12'

      fy1.should_not be_adjacent fy2
      fy2.should_not be_adjacent fy1
    end
  end

  describe "object comparison" do
    it "is less than for earlier FYs" do
      UkFinancialYear.new(Date.parse '5 Apr 2011').should be < UkFinancialYear.new(Date.parse '6 Apr 2011')
    end

    it "is greater than for later FYs" do
      UkFinancialYear.new(Date.parse '6 Apr 2011').should be > UkFinancialYear.new(Date.parse '5 Apr 2011')
    end
  end

  describe "creation without date" do
    it "is the current financial year" do
      Timecop.freeze(Date.parse '5 Jul 2010') do
        UkFinancialYear.new.should == UkFinancialYear.from_s('2010/11')
      end
    end
  end
end