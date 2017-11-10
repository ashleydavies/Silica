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

You can also use attributes such as `sc-show` to conditionally display or hide elements:

```
<div sc-show="count > 2">
  More than 2!
</div>
```

Variables are resolved respective to your application class. *Only* variables which have had silica_binding declared for them will result in automatic updates to any conditional behaviour dependent on them. Conditional behaviour is based on a dependency graph generated during the previous calculation of the property, so refreshing these conditions is fairly performant complexity-wise.

If you have properties which are more complicated, you can express this with silica_dynamic:

```
<!-- in a Ruby file -->
class Complicated
  silica_binding :forename
  silica_binding :surname
  silica_dynamic :fullName do
    self.forename + self.surname
  end

  def init
    self.forename = self.surname = ""
  end
end

<!-- in HTML -->
<div sc-app="Complicated">
  Forename: <input type="text" sc-model="forename"></input>
  <br/>
  Surname: <input type="text" sc-model="surname"></input>
  <br/>
  Full name: <span sc-text-bind="fullName"/>
</div>
```

Properties declared with silica_dynamic will be automatically recalculated henever any of their silica bound (whether through silica_dynamic or silica_binding) variables change, and will cause any appropriate UI changes to take place.
