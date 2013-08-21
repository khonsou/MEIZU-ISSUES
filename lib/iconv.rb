# redmine lib uses Iconv internally. 
# This class is to remove warning for ruby 1.9 and 
# to make redmine lib work in ruby 2.0

class Iconv
  def initialize(to, from)
    @to = to
    @from = from
  end

  def self.iconv(to, from, *strs)
    strs.collect {|s| s.encode(to, from)} 
  end

  def self.conv(to, from, str)
    str.encode(to, from)
  end

  def close
  end

  def conv(str)
    str.encode(@to, @from)
  end

end

