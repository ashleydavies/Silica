require 'opal'
require 'opal-parser'
require 'opal-jquery'

class Class
  def silica_binding(attr)
    raise "' is a forbidden character in Silica variables (#{attr})" if attr.include? "'"
    self.class_eval "def #{attr};@_silica_#{attr};end"
    self.class_eval "def #{attr}=(val);@_silica_#{attr}=val;Silica.notify(#{self}, self, '#{attr}');end"
  end
end

class Silica
  def self.start()
    Silica.new.init
  end

  @@subscribed = {}
  def self.notify(clazz, instance, attr) 
    if @@subscribed.has_key? clazz.to_s
      if @@subscribed[clazz.to_s].has_key? attr
        @@subscribed[clazz.to_s][attr].call(instance.send attr)
      end
    end
  end

  def self.subscribe(className, attr, &callback)    
    @@subscribed[className] = {} unless @@subscribed.has_key? className
    @@subscribed[className][attr] = callback;
  end

  def init
    Element['[silica-app]'].each do |element|
      app_name = element.attr 'silica-app'
      app = (Object.const_get (app_name)).new

      (element.find '[silica-text-bind]').each do |textElement|
        Silica.subscribe(app_name, textElement.attr('silica-text-bind')) do |t|
          textElement.text = app.send(textElement.attr 'silica-text-bind')
        end
      end

      app.init

      (element.find '[silica-on-click]').each do |button|
        button.on :click do
          app.send button.attr('silica-on-click')
        end
      end
    end
  end
end

