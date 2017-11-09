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

# Start silica
Silica.start

