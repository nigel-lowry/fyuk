require 'spec_helper'

describe UkFinancialYear do

  subject { UkFinancialYear.from_s '2012/13' }

  its(:first_day) { is_expected.to eq('6 Apr 2012'.to_date) }
  its(:last_day) { is_expected.to eq('5 Apr 2013'.to_date) }
  its(:next) { is_expected.to eq(UkFinancialYear.from_s '2013/14') }
  its(:previous) { is_expected.to eq(UkFinancialYear.from_s '2011/12') }
  its(:to_s) { is_expected.to eq('2012/13') }

  specify { expect(UkFinancialYear.new '6 Apr 2011'.to_date).to eq(UkFinancialYear.new '7 Apr 2011'.to_date) }
  specify { expect(UkFinancialYear.new '5 Apr 2011'.to_date).to_not eq(UkFinancialYear.new '6 Apr 2011'.to_date) }

  specify { expect(UkFinancialYear.new '5 Apr 2011'.to_date).to be < UkFinancialYear.new('6 Apr 2011'.to_date) }

  describe "#to_s" do
    specify { expect(UkFinancialYear.new('7 Apr 2011'.to_date).to_s).to eq('2011/12') }
    specify { expect(UkFinancialYear.new('7 Apr 1999'.to_date).to_s).to eq('1999/00') }
  end

  describe "#first_day" do
    specify { expect(UkFinancialYear.new('4 Apr 2011'.to_date).first_day).to eq('6 Apr 2010'.to_date) }
    specify { expect(UkFinancialYear.new('5 Apr 2011'.to_date).first_day).to eq('6 Apr 2010'.to_date) }
    specify { expect(UkFinancialYear.new('6 Apr 2011'.to_date).first_day).to eq('6 Apr 2011'.to_date) }
    specify { expect(UkFinancialYear.new('7 Apr 2011'.to_date).first_day).to eq('6 Apr 2011'.to_date) }
  end

  describe "#last_day" do
    specify { expect(UkFinancialYear.new('4 Apr 2011'.to_date).last_day).to eq('5 Apr 2011'.to_date) }
    specify { expect(UkFinancialYear.new('5 Apr 2011'.to_date).last_day).to eq('5 Apr 2011'.to_date) }
    specify { expect(UkFinancialYear.new('6 Apr 2011'.to_date).last_day).to eq('5 Apr 2012'.to_date) }
    specify { expect(UkFinancialYear.new('7 Apr 2011'.to_date).last_day).to eq('5 Apr 2012'.to_date) }
  end

  describe "#.include?" do
    subject { UkFinancialYear.from_s '2012/13' }

    it { should_not include '5 Apr 2012'.to_date }
    it { should include '6 Apr 2012'.to_date }
    it { should include '5 Apr 2013'.to_date }
    it { should_not include '6 Apr 2013'.to_date } 
  end

  describe "#from_s" do
    specify { expect(UkFinancialYear.from_s('1997/98').to_s).to eq('1997/98') }
    specify { expect(UkFinancialYear.from_s('1998/99').to_s).to eq('1998/99') }
    specify { expect(UkFinancialYear.from_s('1999/00').to_s).to eq('1999/00') }
    specify { expect(UkFinancialYear.from_s('2000/01').to_s).to eq('2000/01') }

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
    subject { UkFinancialYear.from_s '2011/12' }

    it { is_expected.to_not be_adjacent UkFinancialYear.from_s '2009/10' }
    it { is_expected.to be_adjacent UkFinancialYear.from_s '2010/11' }
    it { is_expected.to be_adjacent UkFinancialYear.from_s '2012/13' }
    it { is_expected.to_not be_adjacent UkFinancialYear.from_s '2013/14' }
  end

  describe "#before? and #after?" do
    subject { UkFinancialYear.from_s '2011/12' }

    it { is_expected.to be_before UkFinancialYear.from_s('2012/13') }
    it { is_expected.to be_before UkFinancialYear.from_s('2012/13').first_day }
    it { is_expected.to be_after UkFinancialYear.from_s('2010/11') }
    it { is_expected.to be_after UkFinancialYear.from_s('2010/11').last_day }
  end

  describe "creation without date" do
    it "is the current financial year" do
      Timecop.freeze('5 Jul 2010'.to_date) do
        UkFinancialYear.new.should == UkFinancialYear.from_s('2010/11')
      end
    end
  end

  describe "#fy_before" do
    subject { UkFinancialYear.from_s '2012/13' }

    it "raises an error for a date before the FY" do
      expect {
        subject.period_before('5 Apr 2012'.to_date)
      }.to raise_error(
        RuntimeError,
        /2012-04-05 is before FY 2012\/13/
      )
    end

    it "raises an error for a date after the FY" do
      expect {
        subject.period_before('6 Apr 2013'.to_date)
      }.to raise_error(
        RuntimeError,
        /2013-04-06 is after FY 2012\/13/
      )
    end

    specify { expect(subject.period_before('6 Apr 2012'.to_date)).to eq('6 Apr 2012'.to_date...'6 Apr 2012'.to_date) }
    specify { expect(subject.period_before('7 Apr 2012'.to_date)).to eq('6 Apr 2012'.to_date...'7 Apr 2012'.to_date) }
    specify { expect(subject.period_before('8 Apr 2012'.to_date)).to eq('6 Apr 2012'.to_date...'8 Apr 2012'.to_date) }
  end
end