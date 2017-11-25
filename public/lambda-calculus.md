---
title: Lambda Calculus
---

Lambda Calculus is often cited as the first functional programming language.
Though there have been many attempts to derive a formal programming language
from Lambda Calculus, the original language in its purest form
**does not support** the following:
 - named functions
 - primitives
 - objects
 - functions without a return value
 - functions with multiple parameters

Here is what the syntax does allow:
 - Defining an anonymous function <br/>
   `λx.x` defines the identity function
   - `λ` marks the start of a function definition
   - `.` marks the start of the function body (right-associative)
 - Applying a function <br />
   `xy` means "apply `x` to `y`"

Some things to notice:
 - Everything in Lambda Calculus is a function with one parameter and one return value
 - The "multiple parameters problem" is solved by the fact that functions always return functions
   - `λx.λy.yx` defines a function that takes a function `x`, then returns a function, which takes
   a function `y`, then returns `y` applied to `x`
   - Here's how you would write that in Clojure: `(fn [x] (fn [y] (y x)))`
   - We use [currying](https://en.wikipedia.org/wiki/Currying) to *express* multiple parameters

Strictly speaking, Lambda Calculus does not support any non-function values.
However, in order to "evaluate" an expression, we need to define a base case.
Therefore, we will define the following "integer" representations:
 - 0: `λs.λz.z` function that ignores its parameter and returns the identity function
 - 1: `λs.λz.sz` function that applies its parameter once to the parameter of the function it returns
 - 2: `λs.λz.ssz` function that applies its parameter twice to the parameter of the function it returns
 - etc.
These definitions only serve to help us "evaluate" expressions!

Let's look at how we would define Clojure's `inc` function in Lamda Calculus:
```
λn.λs.λz.s(n s z)          #=> parenthesis help us describe order of operations
λn.λs.λz.s(n s z) 3        #=> let's apply this function to the value 3
λs.λz.s(3 s z)             #=> starting from the outside, we replace 3 for n
λs.λz.s((λa.λb.aaab) s z)  #=> 3 as a function call can be replaced for its "function representation"
λs.λz.s((λb.sssb) z)       #=> apply "3" to s...
λs.λz.s((λz.sssz))         #=> ...then to z
λs.λz.ssssz                #=> at this point, we can extract the nested function
4                          #=> we arrive at the "function" representation of 4!
```

## Resources
- http://zeroturnaround.com/rebellabs/what-is-lambda-calculus-and-why-should-you-care/
- http://www.toves.org/books/lambda/
- http://www.inf.fu-berlin.de/lehre/WS03/alpi/lambda.pdf
