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
