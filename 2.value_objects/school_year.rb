# frozen_string_literal: true

# SchoolYear Value Object class
SchoolYear = Struct.new(:start_year, :end_year) do
  def initialize(start_year, end_year)
    raise ArgumentError unless start_year.is_a?(Integer)
    raise ArgumentError unless end_year.is_a?(Integer)
    raise ArgumentError unless start_year >= 0
    raise ArgumentError unless start_year + 1 == end_year

    super(start_year, end_year)
  end

  def self.from_name(name)
    start_year, end_year = *name.split('/')
    from_years(start_year, end_year)
  end

  def self.from_years(start_year_string, end_year_string)
    new(Integer(start_year_string), Integer(end_year_string))
  end

  def self.from_date(date)
    year = date.year
    if date < Date.new(year, 8, 1)
      new(year - 1, year)
    else
      new(year, year + 1)
    end
  end

  def self.current
    from_date(Date.current)
  end

  def name
    [start_year, end_year].join('/')
  end

  def next
    self.class.new(start_year.next, end_year.next)
  end

  def prev
    self.class.new(start_year.prev, end_year.prev)
  end

  def starts_at
    Date.new(start_year, 8, 1)
  end

  def ends_at
    Date.new(end_year, 7, 31)
  end

  private :start_year=, :end_year=
end

class Klass
  attr_accessor :school_year
end

klass = Klass.new
klass.school_year = SchoolYear.new(2020, 2021)
puts klass.school_year
