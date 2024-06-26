# frozen_string_literal: true

require('./school_year')
require('date')

RSpec.describe SchoolYear do
  describe '#initializer' do
    context 'start_year is Integer' do
      it 'does not rise an Error' do
        expect(SchoolYear.new(2000, 2001)).to be_a SchoolYear
      end
    end

    context 'start_year is not Integer' do
      it 'rises an Error' do
        expect { SchoolYear.new('a', 2000) }.to raise_error(ArgumentError)
      end
    end

    context 'start_year is greater or equal to 0' do
      it 'does not rise an Error' do
        expect(SchoolYear.new(0, 1)).to be_a SchoolYear
      end
    end

    context 'start_year is less 0' do
      it 'rises an Error' do
        expect { SchoolYear.new(-1, 2000) }.to raise_error(ArgumentError)
      end
    end

    context 'there is 1 year different between start_year and end_year' do
      it 'does not rise an Error' do
        expect(SchoolYear.new(2000, 2001)).to be_a SchoolYear
      end
    end

    context 'there is more than 1 year different between start_year and end_year' do
      it 'rises an Error' do
        expect { SchoolYear.new(2000, 2010) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#current' do
    context 'date is before 1.8' do
      subject { described_class.from_date(Date.new(2000, 7, 31)) }
      it { expect(subject).to eq(SchoolYear.new(1999, 2000)) }
    end

    context 'date is after 1.8' do
      subject { described_class.from_date(Date.new(2000, 8, 1)) }
      it { expect(subject).to eq(SchoolYear.new(2000, 2001)) }
    end
  end

  describe '#name' do
    subject { described_class.new(2000, 2001) }
    it { expect(subject.name).to eq('2000/2001') }
  end

  describe '#next' do
    subject { described_class.new(2000, 2001) }
    it { expect(subject.next).to eq(SchoolYear.new(2001, 2002)) }
  end

  describe '#prev' do
    subject { described_class.new(2000, 2001) }
    it { expect(subject.prev).to eq(SchoolYear.new(1999, 2000)) }
  end

  describe '#starts_at' do
    it do
      expect(SchoolYear.new(2000, 2001).starts_at).to(eq(Date.new(2000, 8, 1)))
    end
  end

  describe '#ends_at' do
    it do
      expect(SchoolYear.new(2000, 2001).ends_at).to(eq(Date.new(2001, 7, 31)))
    end
  end
end
