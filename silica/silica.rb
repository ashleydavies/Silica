require 'opal'
require 'opal-parser'
require 'opal-jquery'

class Class
  def silica_binding(attr)
    define_method(attr) do
      Silica.notify_read(self.class, self, attr)
      instance_variable_get("@_silica_#{attr}")
    end

    define_method("#{attr}=") do |val|
      instance_variable_set("@_silica_#{attr}", val)
      Silica.notify(self.class, self, attr)
    end
  end

  def silica_dynamic(attr, &block)
    @@silica_eval_functions = {} if @silica_eval_functions.nil?
    @@silica_eval_functions[attr] = block

    define_method(attr) do
      Silica.notify_read(self.class, self, attr.to_s)
      
      self.send "silica_calc_#{attr}", true if
        instance_variable_get("@_silica_#{attr}").nil?

      instance_variable_get("@_silica_#{attr}")
    end

    define_method "silica_calc_#{attr}" do |skip = false|
      val = nil
      subscribedTo = []
      
      dependencies = Silica.monitor_dependencies do
        val = self.send "silica_calc_inner_#{attr}"
      end
      
      instance_variable_set("@_silica_#{attr}", val)

      Silica.notify(self.class, self, attr) unless skip

      dependencies.each do |dependency|
        subscribedTo << {
          :class => dependency[:class],
          :attribute => dependency[:attribute],
          :callback => Silica.subscribe(dependency[:class].to_s, dependency[:attribute]) do
            -> {
              subscribedTo.each do |subscription|
                puts @@subscribed[subscription[:class].to_s][subscription[:attribute]]
                puts subscription[:callback]
                @@subscribed[subscription[:class].to_s][subscription[:attribute]] -= [subscription[:callback]]
                puts @@subscribed[subscription[:class].to_s][subscription[:attribute]]
              end

              self.send "silica_calc_#{attr}"
            }
          end
        }
      end
    end

    define_method "silica_calc_inner_#{attr}", block
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
    queue = []

    if @@subscribed.has_key? clazz.to_s
      if @@subscribed[clazz.to_s].has_key? attr
        @@subscribed[clazz.to_s][attr].each do |block|
          ret = block.call(instance.send attr)
          queue << ret if ret.respond_to? :call
        end
      end
    end

    queue.each(&:call)
  end

  def self.notify_read(clazz, instance, attr)
    return if @@dependencies.nil?
    @@dependencies << { :class => clazz, :attribute => attr }
  end

  def self.subscribe(className, attr, &callback)    
    @@subscribed[className] = {}       unless @@subscribed.has_key? className
    @@subscribed[className][attr] = [] unless @@subscribed[className].has_key? attr
    @@subscribed[className][attr].push callback;
    callback
  end

  def self.monitor_dependencies(&block)
    old_dependencies = @@dependencies
    @@dependencies = []
    block.call
    dependencies = @@dependencies
    @@dependencies = old_dependencies
    return dependencies.uniq
  end

  def init
    findElements(Element, 'app').each do |found|
      element = found[:element]
      app_name = found[:value]
      app = (Object.const_get (app_name)).new

      app.init

      # Bind up text bindings
      findElements(element, 'text-bind').each do |found|
        Silica.subscribe(app_name, found[:value]) do |t|
          found[:element].text = app.send found[:value]
        end
      end

      # Bind up two-way data bound models
      findElements(element, 'model').each do |found|
        lastValue = nil

        # Subscribe to changes to dependents for output directional binding
        Silica.subscribe(app_name, found[:value]) do |t|
          found[:element].value = app.send found[:value]
        end

        # Hook up input for input directional binding
        found[:element].on :input do
          return if lastValue == found[:element].value
          app.send "#{found[:value]}=", found[:element].value
          lastValue = found[:element].value
        end
      end

      # Bind up hide/show elements
      findElements(element, "show").each do |found|
        subscribeTo app, found do |show|
          found[:element].css 'display', show ? '' : 'none'
        end
      end

      # Bind up events
      Events.each do |event|
        findElements(element, [event, "on-#{event}"]).each do |found|
          found[:element].on event do
            app.send(found[:element].attr found[:attribute])
          end
        end
      end
    end

    @@subscribed.each_pair do |_, attributes| 
      attributes.each_pair do |_, methods|
        methods.each(&:call)
      end
    end

    puts @@subscribed
  end

  def subscribeTo(app, elemFound, &block)
    subscribedTo = []
    result = nil

    dependencies = Silica.monitor_dependencies do
      result = app.instance_eval elemFound[:value]
    end

    block.call result

    dependencies.each do |dependency|
      subscribedTo << {
        :class => dependency[:class],
        :attribute => dependency[:attribute],
        :callback => Silica.subscribe(dependency[:class].to_s, dependency[:attribute]) do
          -> {
            subscribedTo.each do |subscription|
              @@subscribed[subscription[:class].to_s][subscription[:attribute]] -= [subscription[:callback]]
            end

            subscribeTo(app, elemFound, &block)
          }
        end
      }
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

