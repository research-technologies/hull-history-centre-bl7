module DateFormatter

  UNKNOWN_DATE = 'unknown'

  def unknown_dates
    ['0', '0000', 'n.d.', 'no date', 'not dated', 'unknown']
  end

  def expand_dates(date_string)
    date_range = Range.new(*date_string.split('-'))
    integer_dates(date_range)
  rescue
    nil
  end

  def standardized_dates(date_string)
    dates = Array(date_string).map do |date|
      unknown_dates.include?(date.downcase) ? UNKNOWN_DATE : date
    end
    dates = dates.first if dates.length == 1
    dates
  end

  def integer_dates(date_string)
    dates = standardized_dates(date_string)

    dates = Array(dates).map do |date|
      date == UNKNOWN_DATE ? nil : date.to_i
    end.compact

    if dates.empty?
      nil
    elsif dates.length == 1
      dates.first
    else
      dates
    end
  end

  # For the purpose of sorting, we need to reduce the date(s)
  # into a single year.  If it's a range of years, just pick
  # the first year in the range.
  def sortable_date(date_string)
    return nil if date_string.nil?
    if date_string.is_a? Array
      Array(integer_dates(date_string)).first
    elsif date_string.match('-')
      Array(expand_dates(date_string)).first
    else
      Array(integer_dates(date_string)).first
    end
  end

end
