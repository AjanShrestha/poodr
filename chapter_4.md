# Creating Flexible Interfaces

> Classes are what you see in your text editor and what you check in to your source code repository. There is design detail that must be captured at this level but an object-oriented application is more than just classes. It is made up of classes but defined by messages. Classes control what’s in your source code repository; messages reflect the living, animated application. Design, therefore, must be concerned with the messages that pass between objects. It deals not only with what objects know (their responsibilities) and who they know (their dependencies), but how they talk to one another. The conversation between objects takes place using their interfaces; this chapter explores creating flexible interfaces that allow applications to grow and to change.

## Understanding Interfaces

![Communication Patterns](./images/4.1.png)
In the first application, the messages have no apparent pattern. Every object may send any message to any other object. If the messages left visible trails, these trails would eventually draw a woven mat, with each object connected to every other.

In the second application, the messages have a clearly defined pattern. Here the objects communicate in specific and well-defined ways. If these messages left trails, the trails would accumulate to create a set of islands with occasional bridges between them.

The objects in the first application are difficult to reuse. Each one exposes too much of itself and knows too much about its neighbors. This excess knowledge results in objects that are finely, explicitly, and disastrously tuned to do only the things that they do right now. No object stands alone; to reuse any you need all, to change one thing you must change everything.

The second application is composed of plug-able, component-like objects. Each reveals as little about itself, and knows as little about others, as possible.

The design issue in the first application is not necessarily a failure of dependency injection or single responsibility. Those techniques, while necessary, are not enough to prevent the construction of an application whose design causes you pain. **The roots of this new problem lie not in what each class does but with what it reveals.** In the first application each class reveals all. Every method in any class is fair game to be invoked by any other object.

_Experience tells you that all the methods in a class are not the same; some are more general or more likely to change than others._ The first application takes no notice of this. It allows all methods of any object, regardless of their granularity, to be invoked by others.

In the second application, the message patterns are visibly constrained. This application has some agreement, some bargain, about which messages may pass between its objects. Each object has a clearly defined set of methods that it expects others to use.
These exposed methods comprise the class’s public interface.

## Defining Interfaces

> Each of your classes is like a kitchen. The class exists to fulfill a single responsibility but implements many methods. These methods vary in scale and granularity and range from broad, general methods that expose the main responsibility of the class to tiny utility methods that are only meant to be used internally. Some of these methods represent the menu for your class and should be public; others deal with internal implementation details and are private.

### Public Interfaces

The methods that make up the public interface of your class comprise the face it presents to the world. They:

- Reveal its primary responsibility
- Are expected to be invoked by others
- Will not change on a whim
- Are safe for others to depend on
- Are thoroughly documented in the tests

### Private Interfaces

All other methods in the class are part of its private interface. They:

- Handle implementation details
- Are not expected to be sent by other objects
- Can change for any reason whatsoever
- Are unsafe for others to depend on
- May not even be referenced in the tests

### Responsibilities, Dependencies, and Interfaces

_Creating classes that have a single responsibility—a single purpose._ If you think of a class as having a single purpose, then the things it does (its more specific responsibilities) are what allows it to fulfill that purpose. There is a correspondence between the statements you might make about these more specific responsibilities and the classes’ public methods. Indeed, public methods should read like a description of responsibilities. **The public interface is a contract that articulates the responsibilities of your class.**

_A class should depend only on classes that change less often than it
does._ **The public parts of a class are the stable parts; the private parts are the changeable parts.** When you mark methods as public or private you tell users of your class upon which methods they may safely depend. When your classes use the public methods of others, you trust those methods to be stable. When you decide to depend on the private methods of others, you understand that you are relying on something that is inherently unstable and are thus increasing the risk of being affected by a distant and
unrelated change.

## Finding the Public Interface

Finding and defining public interfaces is an art. The design goal, as always, is to retain maximum future flexibility while writing only enough code to meet today’s requirements. Good public interfaces reduce the cost of unanticipated change; bad public interfaces raise it.

### Constructing an Intention

Whether you are conscious of them or not, you have already formed some intentions of your own. These classes spring to mind because they represent nouns in the application that have both data and behavior. Call them domain objects. They are obvious because they are persistent; they stand for big, visible real-world things that will end up with a representation in your database.

Domain objects are easy to find but they are not at the design center of your application. Instead, they are a trap for the unwary. If you fixate on domain objects you will tend to coerce behavior into them. **Design experts notice domain objects without concentrating on them; they focus not on these objects but on the messages that pass between them. These messages are guides that lead you to discover other objects, ones that are just as necessary but far less obvious.**

Before you sit at the keyboard and start typing you should form an intention about the objects and the messages needed to satisfy this use case. You would be best served if you had a simple, inexpensive communication enhancing way to explore design that did not require you to write code -- _Sequence Diagrams_

### Using Sequence Diagrams

> Sequence diagrams are defined in the Unified Modeling Language (UML) and are one of many diagrams that UML supports.

Sequence diagrams are quite handy. They provide a simple way to experiment with different object arrangements and message passing schemes. _They bring clarity to your thoughts and provide a vehicle to collaborate and communicate with others._ Think of them as a lightweight way to acquire an intention about an interaction. Draw them on a whiteboard, alter them as needed, and erase them when they’ve served their purpose.

Drawing sequence diagram exposes the message passing between the objects and prompts you to ask the question: “Should this receiver be responsible for responding to this message?”

Therein lies the value of sequence diagrams. _They explicitly specify the messages that pass between objects, and because objects should only communicate using public interfaces, sequence diagrams are a vehicle for exposing, experimenting with, and ultimately defining those interfaces._

Also, notice now that you have drawn a sequence diagram, this design conversation has been inverted. **The previous design emphasis was on classes and who and what they knew. Suddenly, the conversation has changed; it is now revolving around messages. Instead of deciding on a class and then figuring out its responsibilities, you are now deciding on a message and figuring out where to send it.**

> _This transition from class-based design to message-based design is a turning point in your design career._ The message-based perspective yields more flexible applications than does the class-based perspective. Changing the fundamental design question from “I know I need this class, what should it do?” to **“I need to send this message, who should respond to it?”** is the first step in that direction.

![A simple sequence diagram](./images/4.3.png)
![Moe talks to trip and bicycle](./images/4.4.png)

**You don’t send messages because you have objects, you have objects because you send messages.**

### Asking for “What” Instead of Telling “How”

> The distinction between a message that asks for what the sender wants and a message that tells the receiver how to behave may seem subtle but the consequences are significant. Understanding this difference is a key part of creating reusable classes with well-defined public interfaces.

![How](./images/4.5.png)

![What](./images/4.6.png)

### Seeking Context Independence

The context that an object expects has a direct effect on how difficult it is to reuse. Objects that have a simple context are easy to use and easy to test; they expect few things from their surroundings. Objects that have a complicated context are hard to use and hard to test; they require complicated setup before they can do anything.

The best possible situation is for an object to be completely independent of its context. An object that could collaborate with others without knowing who they are or what they do could be reused in novel and unanticipated ways.

Context is a coat that Trip wears everywhere; any use of Trip, be it for testing or otherwise, requires that its context be established. Preparing a trip always requires preparing bicycles and in doing so Trip always sends the prepare_bicycle message to its Mechanic. You cannot reuse Trip unless you provide a Mechanic-like object that can respond to this message.

You already know the technique for collaborating with others without knowing who they are—_dependency injection_. The new problem here is for Trip to invoke the correct behavior from Mechanic without knowing what Mechanic does. Trip wants to collaborate with Mechanic while maintaining context independence.

![Seeking Context Independence](./images/4.7.png)

At first glance this seems impossible. Trips have bicycles, bicycles must be prepared, and mechanics prepare bicycles. Having Trip ask Mechanic to prepare a Bicycle seems inevitable.

However, it is not. The solution to this problem lies in the distinction between what and how, and arriving at a solution requires concentrating on what Trip wants.

What Trip wants is to be prepared. The knowledge that it must be prepared is completely and legitimately within the realm of Trip’s responsibilities. However, the fact that bicycles need to be prepared may belong to the province of Mechanic. The need for bicycle preparation is more how a Trip gets prepared than what a Trip wants.

Figure illustrates a third alternative sequence diagram for Trip preparation. In this example, Trip merely tells Mechanic what it wants, that is, to be prepared, and passes itself along as an argument.

In this sequence diagram, Trip knows nothing about Mechanic but still manages to collaborate with it to get bicycles ready. Trip tells Mechanic what it wants, passes self along as an argument, and Mechanic immediately calls back to Trip to get the list of the Bicycles that need preparing.

In the Figure:

- ThepublicinterfaceforTripincludesbicycles.
- The public interface for Mechanic includes prepare_trip and perhaps prepare_bicycle.
- Trip expects to be holding onto an object that can respond to prepare_trip.
- Mechanic expects the argument passed along with prepare_trip to respond to bicycles.

All of the knowledge about how mechanics prepare trips is now isolated inside of Mechanic and the context of Trip has been reduced. Both of the objects are now easier to change, to test, and to reuse.

### Trusting Other Objects

If objects were human and could describe their own relationships, in Figure 4.5 Trip would be telling Mechanic: “I know what I want and I know how you do it;” in Figure 4.6: “I know what I want and I know what you do” and in Figure 4.7: _“I know what I want and I trust you to do your part.”_

This blind trust is a keystone of object-oriented design. It allows objects to collaborate without binding themselves to context and is necessary in any application that expects to grow and change.

### Using Messages to Discover Objects

Figure 4.3 was a literal translation of this use case, one in which Trip had too much responsibility. Figure 4.4 was an attempt to move the responsibility for finding available bicycles from Trip to Bicycle, but in doing so it placed an obligation on Customer to know far too much about what makes a trip “suitable.”

Neither of these designs is very reusable or tolerant of change. These problems are revealed, inescapably, in the sequence diagrams. Both designs contain a violation of the single responsibility principle. In Figure 4.3, Trip knows too much. In Figure 4.4, Customer knows too much, tells other objects how to behave, and requires too much context.

It is completely reasonable that Customer would send the suitable_trips message. That message repeats in both sequence diagrams because it feels innately cor- rect. It is exactly what Customer wants. **The problem is not with the sender, it is with the receiver. You have not yet identified an object whose responsibility it is to implement this method.**

_This application needs an object to embody the rules at the intersection of Customer, Trip and Bicycle. The suitable_trips method will be part of its public interface._

The realization that you need an as yet undefined object is one that you can arrive at via many routes. The advantage of discovering this missing object via sequence diagrams is that the cost of being wrong is very low and the impediments to changing your mind are extremely few. The sequence diagrams are experimental and will be dis- carded; your lack of attachment to them is a feature. They do not reflect your ultimate design, but instead they create an intention that is the starting point for your design.

Perhaps the application should contain a TripFinder class. Figure 4.8 shows a sequence diagram where a TripFinder is responsible for finding suitable trips.

![Moe asks the TripFinder for a suitable trip](./images/4.8.png)

TripFinder contains all knowledge of what makes a trip suitable. It knows the rules; its job is to do whatever is necessary to respond to this message. It provides a consistent public interface while hiding messy and changeable internal implementation details.

Moving this method into TripFinder makes the behavior available to any other object. In the unknown future perhaps other touring companies will use TripFinder to locate suitable trips via a Web service. Now that this behavior has been extracted from Customer, it can be used, in isolation, by any other object.

## Writing Code That Puts Its Best (Inter)Face Forward

The clarity of your interfaces reveals your design skills and reflects your self-discipline. Because design skills are always improving but never perfected, and because even today’s beautiful design may look ugly in light of tomorrow’s requirement, it is difficult to create perfect interfaces.

This, however, should not deter you from trying. Interfaces evolve and to do so they must first be born. It is more important that a well-defined interface exist than that it be perfect.

_Think_ about interfaces. Create them intentionally. It is your interfaces, more than all of your tests and any of your code, that define your application and determine its future.

### Create Explicit Interfaces

Your goal is to write code that works today, that can easily be reused, and that can be adapted for unexpected use in the future. Other people will invoke your methods; it is your obligation to communicate which ones are dependable.

Every time you create a class, declare its interfaces. Methods in the public
interface should

- Be explicitly identified as such
- Be more about what than how
- Have names that, insofar as you can anticipate, will not change
- Take a hash as an options parameter

Be just as intentional about the private interface; make it inescapably obvious. Tests, because they serve as documentation, can support this endeavor. Either do not test private methods or, if you must, segregate those tests from the tests of public methods. Do not allow your tests to fool others into unintentionally depending on the changeable, private interface.

Ruby provides three relevant keywords: _public, protected, and private_. Use of these keywords serves two distinct purposes. First, they indicate which methods are stable and which are unstable. Second, they control how visible a method is to other parts of your application. These two purposes are very different. Conveying informa- tion that a method is stable or unstable is one thing; attempting to control how others use it is quite another.

---

#### Public, Protected, and Private Keywords

The _private_ keyword denotes the least stable kind of method and provides the most restricted visibility. Private methods must be called with an implicit receiver, or, inversely, may never be called with an explicit receiver.

The *protected *keyword also indicates an unstable method, but one with slightly different visibility restrictions. Protected methods allow explicit receivers as long as the receiver is self or an instance of the same class or subclass of self.

The _public_ keyword indicates that a method is stable; public methods are visible everywhere.

---

The keywords don’t deny access, they just make it a bit harder. Using them sends two messages:

- You believe that you have better information today than programmers will have in the future.
- You believe that those future programmers need to be prevented from accidentally using a method that you currently consider unstable.

### Honor the Public Interface of Others

Do your best to interact with other classes using only their public interfaces. Assume that the authors of those classes were just as intentional as you are now and they are trying desperately, across time and space, to communicate which methods are dependable. The public/private distinctions they made are intended to help you and it’s best to heed them.

If your design forces the use of a private method in another class, first rethink your design. It’s possible that a committed effort will unearth an alternative; you should try very hard to find one.

**A dependency on a private method of an external framework is a form of technical debt. Avoid these dependencies.**

### Exercise Caution When Depending on Private Interfaces

Despite your best efforts you may find that you must depend on a private interface. This is a dangerous dependency that should be isolated using the techniques described in Chapter 3. Even if you cannot avoid using a private method, you can prevent the method from being referenced in many places in your application. Depending on a private interface increases risk; keep this risk to a minimum by isolating the dependency.

### Minimize Context

Construct public interfaces with an eye toward minimizing the context they require from others. **Keep the _what_ versus _how_ distinction in mind; create public methods that allow senders to get what they want without knowing how your class implements its behavior.**

**Conversely, do not succumb to a class that has an ill-defined or absent public interface.** When faced with a situation like that of the Mechanic class in Figure 4.5, do not give up and tell it how to behave by invoking all of its methods. Even if the original author did not define a public interface it is not too late to create one for yourself.

Depending on how often you plan to use this new public interface, it can be a new method that you define and place in the Mechanic class, a new wrapper class that you create and use instead of Mechanic, or a single wrapping method that you place in your own class. **Do what best suits your needs, but create some kind of defined public interface and use it. This reduces your class’s context, making it easier to reuse and simpler to test.**
