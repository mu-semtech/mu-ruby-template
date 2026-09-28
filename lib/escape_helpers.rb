require 'uri'

class String
  def sparql_escape
    '"""' + self.gsub(/[\\"]/) { |s| '\\' + s } + '"""'
  end
end

class URI::Generic
  def sparql_escape
    '<' + self.to_s.gsub(/[\\"<>]/) { |s| '\\' + s } + '>'
  end
end

class Date
  def sparql_escape
    '"' + self.xmlschema + '"^^<http://www.w3.org/2001/XMLSchema#date>'
  end
end

class DateTime
  def sparql_escape
    '"' + self.xmlschema + '"^^<http://www.w3.org/2001/XMLSchema#dateTime>'
  end
end

class Integer
  def sparql_escape
    '"' + self.to_s + '"^^<http://www.w3.org/2001/XMLSchema#integer>'
  end
end

class Float
  def sparql_escape
    '"' + self.to_s + '"^^<http://www.w3.org/2001/XMLSchema#float>'
  end
end

class Boolean
  def sparql_escape
    self ? '"true"^^<http://www.w3.org/2001/XMLSchema#boolean>' : '"false"^^<http://www.w3.org/2001/XMLSchema#boolean>'
  end
end

class TrueClass
  def sparql_escape
    '"true"^^<http://www.w3.org/2001/XMLSchema#boolean>'
  end
end

class FalseClass
  def sparql_escape
    '"false"^^<http://www.w3.org/2001/XMLSchema#boolean>'
  end
end

class Time
  def sparql_escape
    '"' + self.xmlschema + '"^^<http://www.w3.org/2001/XMLSchema#dateTime>'
  end
end
