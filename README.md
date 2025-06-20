# Design Patterns

In this repository that include `code + documents`, I share my study about design patterns and what I have found and learnd.

Generally design patterns are classified in 3 main class:

1. Creational patterns
2. Structural patterns
3. Behavioral patterns

## Source:

- [refacoring.guru](https://refactoring.guru/design-patterns/catalog)

### Creational Patterns

- [Factory Method](./Factory-Method/README.md)

# OOP basics

Object Oriented Programming (OOP), is based on 4 pillars, concepts that differentiate it from other programming paradigms.

![OOP pillars](./assets/oop.png)

1. **Abstraction**: Abstraction is a model of real world object or phenomenon, limited to a specific context, which represents all details relevant to this context with high accuracy and omit all the rest.
2. **Encapsulation**: Encapsulation is the ability of an object to hide parts of its state and behaviors from other objects, exposing only a limited `interface` to the rest of the program. Encapsulate something means to make it `private` for the class, to only be accessible from the methods of that class locally. There is a little bit less restrictive mode called `protected` that makes a member of a class available to subclasses as well. Interfaces and abstract classes or methods in most of programming language are based on `Abstraction` and `Encapsulation` concepts. Interfaces only care about the behavior of an object, and due to this, only methods are defined in interfaces, not the fields.
3. **Inheritance**: Inheritance is the ability to build new classes on top of existing ones. The mean benefit of inheritance is code reuse, because you can use existing class with all methods and attributes, and define new methods and declare new attribute on top of existing one, without duplicating code and use existing code from super class. The consequence of using inheritance is that subclass is implementing the interface that super class do, because subclass cannot hide the existing method in super class. **Also you have to define all abstract methods that are marked as abstract method in super class.** In most programming languages subclass can only extend one superclass, and on the other hand, a class could implement one or more interfaces at once.
4. **Polymorphism**: Polymorphism is the ability of a program to detect the real class of an object and call its implementation even when its real type is unknown in the current context.

## Relations between objects

1. **Association**: Association is a type of relationship in which one object uses or interacts with another. Generally you use association to represent something like a field in a class. For example the relationship with an order with it's related customer.
2. **Dependency**: Dependency is a weaker variant of association that usually implies that there's no permanent link between objects. Dependency (Usually bot not always) means that one object accept another object as a method parameter, instantiate or use another object. A dependency exists between two classes if changes on one class result in modifications in another class.
3. **Composition**: Composition is a relationship between two objects, that one of them act as a container and the other/others play role of components. The difference between this relation with others is that the component only exists as a part of container.
4. **Aggregation**: Aggregation is a less strict variant of composition where one object merely contains a reference to another. The container does't control the lifecycle of the component. The component also can exists without the container and can be linked to several containers at the same time.

Below is the UML diagram of each relationship and also how we represent them in UML:

![UML diagram of objects relationship](./assets/objects-relationships.png)

## What is a design pattern?

**Design Patterns** are solutions to common problems that occur in software design. They're like blueprints that let you customization and solve a recurring problem in the code.

You cannot copy and paste a pattern into your existing code, instead you have to modify them by your own! Design patterns are some concepts that let you think for solving problems in a structural way.

> [!NOTE]
> Patterns are often confused with algorithms, but algorithm is a set of structure that you have to apply them in that specific way to solve the common problem, but patterns are high-level concepts that get customized to solve a problem, by the way the developer implement them.

### Design patterns classification

1. **Creational Patterns**: Creational patterns provide object creation mechanisms that increase flexibility and reuse of existing code.
2. **Structural Patterns**: Structural patterns explain how to struct and assemble objects and classes into larger structure, while keeping it flexible and efficient.
3. **Behavioral Patterns**: Behavioral patterns take care of effective communication and the assignment of responsibilities between objects.

#### Features of good design

1. **Code reuse**
2. **Extensibility**

### Design Principles

#### Encapsulate what varies

Identify which part of your application vary from another and separate them from what stays the same. The main goal of this principle is to reduce the cost on changes the code. **The less time you spend on making the change, the more time you have to implement new features**.

##### Encapsulation in a method level

As an example, imagine that there is a method for calculate the order price including tax. Taxes can be differ due to the location of the customer or changes in regulation later, so put the calculation logic into the method that calculate prices, may not be a good idea.

```text
method getOrderTotal(order) is
    total = 0
    foreach item in order.lineItems
        total += item.price * item.quantity
    
    if (order.country == "US")
        total += total * 0.07 // US sales tax
    else if (order.country == "EU"):
        total += total * 0.20 // European VAT
    return total
```

What we do here is to separate the calculation tax logic into a separate method, and if that method will become more complicated in future, we can separate it into a new class.

```text
method getOrderTotal(order) is
    total = 0
    foreach item in order.lineItems
        total += item.price * item.quantity
    
    total += total * getTaxRate(order.country)
    return total


method getTaxRate(country) is
    if (country == "US")
        return 0.07 // US sales tax
    else if (country == "EU")
        return 0.20 // European VAT
    else
        return 0
```

##### Encapsulation in a class level

We can simply make a new tax calculator class for handling tax calculation, because tax calculation could be complicated to handle in a method in `Order` class. Then we make a aggregation between **Order** and **TaxCalculator** class, and TaxCalculator class would have some private method to calculate taxes for different countries or states.

> [!NOTE]
> Program to an interface not an implementation. Depend on abstractions, not on concrete classes.
> You can tell that a design in flexible enough if you can easily extend it without breaking any existing code.

### Setting up collaboration between classes

If you want to create collaboration between 2 classes, you can follow these steps:

1. Determine what exactly one object needs from the other: which methods does it execute?
2. Describe these methods in a new interface or abstract class.
3. Make the class that is a dependency implement this interface.
4. Now make the second class dependent on this interface rather than on the concrete class. You still can make it work with objects of the original class, but the connection is now much more flexible.

> [!NOTE]
> What I've been notice is that when we're trying to create a subclass, we have to ask ourself that is this class coupled with any other classes or not?
> If answer to that question would be **yes**, then we have to try to remove this coupling between classes, and make them independent from each other.
> For example, imagine that we have a company class, that some employees work for this company. If we create a new instance from this company, then assign some employee to it and try to iterate on this employees and call the `doWork()` method, we have coupling between employee class and also company. The better solution would be to create a new `abstract method` for **Company super class**, and try to implement this in different subclasses, and by achieving this, we'll remove coupling between company and employees.

![Remove coupling example](./assets/remove-coupling-example.png)

### Favor composition over Inheritance

#### Cons of inheritance

1. A subclass can't reduce the interface of superclass
2. When override methods, you have to make sure that the new behavior matches and it's compatible with the base one.
3. Inheritance breaks the encapsulation of the superclass, because the methods and fields of superclass are available in subclass either.
4. Subclasses are tightly coupled to the superclasses: any change in the super class may cause an error in subclasses.
5. Trying to reuse code through inheritance can lead to creating parallel inheritance hierarchies.

#### Composition

There is an alternative to inheritance called **Composition**. The inheritance represent a `is a` relationship **(A Car is a transport)**, while composition represent a `has a` relationship **(A Car has an engine)**.

This principle also applies to **aggregation**, a more relaxed variant of composition where one object may have a reference to the other one, but doesn't manage its lifecycle. *A car has a driver*: But the driver may use another car or prefer to walk instead of driving!

- **Inheritance explosion:**

![Inheritance explosion](./assets/inheritance-explosion.png)

- **Composition over inheritance:**

![Composition over inheritance](./assets/composition-over-inheritance.png)