require 'opal-jquery'

class Test
  silica_binding :title
  silica_binding :entry

  def init
    self.title = "Initial title"
    self.entry = "Eggs"
    puts "Initialized test app"
  end
  
  def buttonClick
    self.title = "Clicked!"
  end

  def doubleClick
    self.entry = "Wow you double clicked a button!"
  end
end

# Start silica
Silica.start

