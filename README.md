# Silica
Silica is an Opal-based Ruby framework for dynamic web-apps, wrapping around opal-jquery (although I will likely transition to direct DOM manipulation in a later version)

It is inspired heavily by Angular 1.0.

Example code:

index.html:
> <div silica-app="AppClass">
>   <h1 silica-text-bind="count"></h1>
>   <button silica-on-click="increment">++</button>
> </div>

AppClass.rb:
> class AppClass
>   silica_binding :count
>    
>   def init
>     self.count = 0
>   end
>   
>   def self.increment
>     self.count += 1
>   end
> end

The binding is handled behind the scenes, with changes being immediately reflected in the document as one would expect.
