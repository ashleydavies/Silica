require 'opal-jquery'

class BasicDemo
  silica_binding :title
  silica_binding :entry

  def init
    self.title = "Initial title"
    self.entry = "Eggs"
  end
  
  def buttonClick
    self.title = "Clicked!"
  end

  def doubleClick
    self.entry = "Wow you double clicked a button!"
  end
end

class Counter
  silica_binding :count
  silica_dynamic :dblCount do
    self.count * 2
  end

  def init
    self.count = 0
  end

  def increment
    self.count += 1
  end
  
  def decrement
    self.count -= 1
  end
end

class AdvancedComputable
  silica_binding :a
  silica_binding :b
  silica_binding :c
  silica_dynamic :sum do
    self.a + self.b + self.c
  end
  silica_dynamic :avg do
    '%.2f' % (self.sum / 3)
  end

  def init
    self.a = self.b = self.c = 0
  end

  def inc_a
    self.a += 1
  end
  
  def dec_a
    self.a -= 1
  end

  def inc_b
    self.b += 1
  end

  def dec_b
    self.b -= 1
  end

  def inc_c
    self.c += 1
  end

  def dec_c
    self.c -= 1
  end
end

class Names
  silica_binding :forename
  silica_binding :surname
  silica_dynamic :fullName do
    "#{self.forename} #{self.surname}"
  end

  def init
    self.forename = ""
    self.surname  = ""
  end
end

# Start silica
Silica.start

