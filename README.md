# Silica
Silica is an Opal-based Ruby framework for dynamic web-apps, wrapping around opal-jquery (although I will likely transition to direct DOM manipulation in a later version)

It is inspired heavily by Angular 1.0.

Example code:

index.html:
```
<div silica-app="AppClass">
  <h1 sc-text-bind="count"></h1>
  <button sc-click="increment">++</button>
</div>
```

AppClass.rb:
```
class AppClass
  silica_binding :count
   
  def init
    self.count = 0
  end
  
  def self.increment
    self.count += 1
  end
end
```

The binding is handled behind the scenes, with changes being immediately reflected in the document as one would expect.

You can achieve two-way data binding additionally by setting `sc-model="<bound attribute>"` on a text input field.
  
Most events are available, including `sc-click`, `sc-mousedown`, `sc-mouseenter`, etc. Named after jQuery's.

If you prefer being more verbose, the following are all equivalent:

```
sc-click
sc-on-click
silica-click
silica-on-click
```
