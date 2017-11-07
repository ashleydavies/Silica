require 'opal-jquery'

class Test
  silica_binding :title

  def init
    self.title = "Initial title"
    puts "Initialized test app"
  end
  
  def buttonClick
    self.title = "Clicked!"
  end
end

# Start silica
Silica.start

