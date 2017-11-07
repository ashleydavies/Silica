require 'opal-jquery'

class Silica
  def init
    Element['[silica-app]'].each do |element|
      app = (Object.const_get (element.attr 'silica-app')).new
      app.init

      (element.find '[silica-text-bind]').each do |textElement|
        textElement.text = app.send(textElement.attr 'silica-text-bind')
      end
    end
  end
end

Silica.new.init

