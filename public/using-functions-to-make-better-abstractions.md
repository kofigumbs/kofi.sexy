# Using Functions to Make Better Abstractions

I spent much of my programming youth in object-oriented land, so I grew accustomed to attaching patterns to object-oriented features.
In particular, when I heard the word "abstraction," my thoughts automatically drifted to interfaces and abstract classes.
I used to think that classes were the only way to eliminate concrete dependencies (code that is tightly coupled to its own implementation details).
I was wrong.
I was wrong because I had an incomplete understanding of functions.


## The Command Pattern
The [Command pattern](https://8thlight.com/blog/ben-spatafora/2014/07/15/command-objects-are-gerunds.html) is a classic object-oriented solution to the concrete-dependency problem.
It's great because it defines a simple interface for passing around actions.
Here's a contrived example depicting how we would use it to hide sorting-algorithm details from the rest of our system.

```python
class Sorter:

  def __init__(self, data, comparator):
    self.data = data
    self.comparator = comparator

  def do(self):
    # ...
    result = self.comparator.compare(self.data[x], self.data[y])
    # ...


class SomeInteractor:

  def present(self):
    # ...
    sorter = Sorter(items, item_comparator)
    SomePresenter().show(sorter)


class SomePresenter:

  def show(self, sorter):
    # ...
    sorted_items = sorter.do()
    # ...

```

There is nothing wrong with this setup from an abstraction point of view.
If we need to write a sorting algorithm, then we should separate it from presentation concerns.
That's not the problem.
There is only a problem if you are reading this and thinking that this is the only way.


## Object-Oriented Thinking (OOT) Syndrome
The Command pattern is very simple, but let's think more about what it really does.
At first glance, I am tempted to think of it as an object pattern.
It looks like the `Sorter` constructor is saying, "Please give me something that knows how to compare."
The `Sorter`, however, probably doesn't *really* want something that knows how to compare.
It just wants to compare!

In my formative years, this difference was lost on me.
"If you want to sort, then you need a sorter. If you want to compare, then you need a comparator."
These musings may sound innocent, but they are symptoms of OOT syndrome.
Objects help us describe and manage state, but sometimes we don't need state to solve our problem.
And when we keep things around that we don't need, they become distractions.
(I'm talking about code here, but feel free to [apply this philosophy to the rest of your life](https://en.wikipedia.org/wiki/Simple_living).)


## Depending on Contracts
The Dependency Inversion Principle, said most concisely as "depend on abstractions, not concretions," has nothing to do with interfaces, specifically.
It's a principle based on contracts.
It allows us to connect pieces of code without each individual piece having too much knowledge or power.
Interfaces are one way we can make contracts, but we can do the same with function signatures!

Using functions as abstractions is not a new concept.
First-class functions are baked into many, though not all, modern languages.
Here's a re-imagination of our sorting solution above, which uses `sort` and `compare` functions instead of objects:

```python
# in quick.py

def sort(data, compare):
  # ...
  result = compare(data[x], data[y])
  # ...


class SomeInteractor:

  def present(self):
    # ...
    SomePresenter().show(quick.sort, utils.compare)


class SomePresenter:

  def show(self, sort, compare):
    # ...
    sorted_items = sort(items, compare)
    # ...

```


## The Human Benefit
First, notice the difference in communicative value.
Our functional approach simplifies our internal language and our external interface.
Programmers in object-oriented contexts can get so used to used to the syndrome that they do not realize that their code is overly specialized.
"Comparator" is not a word, and "sorter" barely qualifies.
We see these funky verb-to-noun transformations so often that we no longer give them much thought.
Maybe instead of [noun-ifying a verb](http://steve-yegge.blogspot.com/2006/03/execution-in-kingdom-of-nouns.html), we should re-function-ify the object!

Second, this solution relieves us of the temptation to carry more state than needed.
Notice that in the `Sorter` class above, we store the data as a field.
So what would happen in this case:

```python
# sorter parameter
sorter = Sorter(items, comparator)
# ...
items = map(items, someAwesomeTransformation)
sorted_items = sorter.do()
```

The `Sorter` runs the risk of operating upon outdated data!
Whenever we duplicate state management (instead of delegating it), we are forced to keep multiple records in sync.
Since our function, however, has discrete entry and exit points, we don't need to manage fields.
Functions' implicit data-in-data-out pattern often lends to simpler and clearer code.


## How To Get There
If you are still recovering from OOT, it's OK.
I am still tempted to rely on state and complicated names.
Here is a tangible approach that might be helpful as you are solving your next concrete-dependency problem:

 0. Identify actions masked as objects by looking for verb-to-noun transformations and state duplication
 0. Refactor those classes using the Command pattern
 0. Combine the constructor and `do` method to create a command function
 0. Keep the function namespaced! We do not want to end up with a bunch of global functions.

---

Sometimes, you need to guarantee that you have a packaged, cohesive group of functionality and state.
In those cases, you probably want to depend on an interface, protocol, or abstract class.
Other times, probably most of the time, you really just want to guarantee that you can do something when you need to.

Next time you face a concrete-dependency problem, think about what you really want your system to do and communicate.
Interfaces are just dandy, but they are not your only option.


_Feb 16, 2016_
