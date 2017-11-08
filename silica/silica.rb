require 'opal'
require 'opal-parser'
require 'opal-jquery'

class Class
  def silica_binding(attr)
    raise "' is a forbidden character in Silica variables (#{attr})" if attr.include? "'"
    self.class_eval "def #{attr};Silica.notify_read(#{self}, self, '#{attr}');@_silica_#{attr};end"
    self.class_eval "def #{attr}=(val);@_silica_#{attr}=val;Silica.notify(#{self}, self, '#{attr}');end"
  end
end

class Silica
  Events = [:click, :dblclick, :mouseenter, :mouseleave, :keypress, :keydown, :keyup, :submit, :change, :focus, :blur, :load, :resize, :scroll, :unload, :input]
  Prefixes = [:silica, :sc]

  def self.start()
    Silica.new.init
  end

  @@subscribed   = {}
  @@dependencies = nil

  def self.notify(clazz, instance, attr) 
    if @@subscribed.has_key? clazz.to_s
      if @@subscribed[clazz.to_s].has_key? attr
        @@subscribed[clazz.to_s][attr].each do |block|
          block.call(instance.send attr)
        end
      end
    end
  end

  def self.notify_read(clazz, instance, attr)
    return if @@dependencies.nil?
    @@dependencies << { :class => clazz, :attribute => attr }
  end

  def self.subscribe(className, attr, &callback)    
    @@subscribed[className] = {}       unless @@subscribed.has_key? className
    @@subscribed[className][attr] = [] unless @@subscribed[className].has_key? attr
    @@subscribed[className][attr].push callback;
  end

  def self.monitor_dependencies(&block)
    old_dependencies = @@dependencies
    @@dependencies = []
    block.call
    dependencies = @@dependencies
    @@dependencies = old_dependencies
    return dependencies
  end

  def init
    findElements(Element, 'app').each do |found|
      element = found[:element]
      app_name = found[:value]
      app = (Object.const_get (app_name)).new

      findElements(element, 'text-bind').each do |found|
        Silica.subscribe(app_name, found[:value]) do |t|
          found[:element].text = app.send found[:value]
        end
      end

      findElements(element, 'model').each do |found|
        lastValue = nil
        Silica.subscribe(app_name, found[:value]) do |t|
          found[:element].value = app.send found[:value]
        end
        found[:element].on :input do
          return if lastValue == found[:element].value
          app.send "#{found[:value]}=", found[:element].value
          lastValue = found[:element].value
        end
      end

      app.init

      (findElements element, "show").each do |found|
        puts ":)"
        # Calculate dependencies
        dependencies = Silica.monitor_dependencies do
          puts "Monitor dependencies"
          app.instance_eval found[:value]
        end
        
        puts dependencies
      end

      Events.each do |event|
        (findElements element, [event, "on-#{event}"]).each do |found|
          found[:element].on event do
            app.send(found[:element].attr found[:attribute])
          end
        end
      end
    end
  end

  def findElements(element, attributes)
    attributes = [attributes] if attributes.is_a? String
    elements = []
    
    attributes.each do |attribute|
      Prefixes.each do |prefix|
        foundAttribute = "#{prefix}-#{attribute}"
        (element.find "[#{foundAttribute}]").each do |foundElement|
          elements.push({ :element   => foundElement,
                          :attribute => foundAttribute,
                          :value     => foundElement.attr(foundAttribute) })
        end
      end
    end
    
    elements
  end
end

