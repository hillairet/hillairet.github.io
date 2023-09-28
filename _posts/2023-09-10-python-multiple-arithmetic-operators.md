---
title: "The surprising behavior of multiple + and - operators in Python"
header:
  image: /assets/images/headers/2023-09-28_pythons-weird-arithmetic.png
  image_description: "An example of Python's weird arithmetic"
  teaser: /assets/images/teasers/2023-09-28_pythons-weird-arithmetic.png
excerpt: Let's explore this strange quirk of the Python language and learn from it.
---

All programming languages have some quirks and strange behavior.
Python is certainly no exception.
I was however quite surprised recently when I found out that Python allows multiple `+` and `-` in a row.
Let's explore this behavior and learn about order of operation from it.

# Use as many `+` and `-` together as you want

I do not know the purpose of this feature but in Python you can write multiple `+` or `-` operators in a row.

```python
>>> 1 +++++++ 1
2
>>> 1 ++++++++++++++++++++ 1
2
>>> 1 ------- 1
0
>>> 1 ------ 1
2
```

The operators behave as if they were shorthands for `* (+1)` and `* (-1)`.
I do not know of any other language that behaves like this.
I also do not see any purpose to it.

The only use case that I can think of is if you need to ask "help" from a fellow developer to deal with your annoying manager:

```python
my_need = 1 --- +++ --- 5
```

There is always someone familiar with morse code in movies so it might work.

# Using multiple `-` with `//` is weird

In case you don't know, the `//` operator performs a division like `/` but instead returns an integer.
When writing `5 // 3` you are doing the exact same calculation as `math.floor(5 / 3)`.

```python
>>> 5 // 3
1
```

Now let's look at this simple calculation using `//`:

```python
>>> 2 - 5 // 2
0
```

The result is as expected since `5 // 2` is equivalent to `floor(5 / 2)` which is equal to 2.

According to the previous section, if we use `--` instead of `-`, we should expect a result of 4.
However here is what we get:

```python
>>> 2 -- 5 // 2
5
```

What is going on here?
Is Python broken?
Are mathematics failing us?

Let's break this down with parentheses to understand what is happening

```python
>>> 2 - (-5 // 2)
5
>>> -5 // 2
-3
>>> math.floor(-5 / 2)
-3
```

The description of the `floor()` function from the [standard library documentation](https://docs.python.org/3/library/math.html#math.floor) explains this result:

> Return the floor of x, the largest integer less than or equal to x.

Now it all makes sense.
The largest integer less than or equal to `-2.5` is `-3`.
So the unexpected result of `2 -- 5 // 2` is due to the order of operations in Python.

The [operator precedence in Python](https://docs.python.org/3/reference/expressions.html#operator-precedence) gives the determination of the sign a higher precedence than the `//` operator.
This is why the sign is applied to `5` before `5 // 2` is performed.

Now it's all clear and nothing else will surprise us, right?

# Adding a `+` into the mix is even weirder

Let's now add a `+` sign to our previous example because why not!

```python
>>> 2 +-- 5 // 2
4
>>> 2 -+- 5 // 2
5
>>> 2 --+ 5 // 2
5
```

Right now might be a good time to open your interpreter and verify that this is for real because you probably don't believe it.

It's as though the `+` doesn't do anything in `-+-` and `--+` compared to using `--` in the previous section.
On the other hand the result is different with `+--`.
Parenthesis can help us here as well:

```python
>>> 2 -- (+ 5 // 2)
4
>>> 2 +- (- 5 // 2)
5
>>> 2 -+ (- 5 // 2)
5
```

Once again the operator precedence clarifies this surprising behavior.
It is mentioned in the documentation that the operators "group left to right" when they have the same precedence.
In the case of `+--` this left to right grouping leads to using the first sign on the left as the sign for the quantity following to the right, in our case `5`.

This is very counter-intuitive!
It means that `+--` is not equivalent to `* (+1) * (-1) * (-1)`.
They might give the same result most of the time but at the end the interpreter treats `+--` like signs to be assigned following the operator precedence rules.

# Never use multiple `+` or `-` operators!

Being able to use multiple `+` and `-` operators in a row is most likely a side effect rather than an intended feature in Python.
In any case I would strongly recommend to refrain from using this feature, even just for the fun.
Most of the time it works as is `+` and `-` could be replaced by `* (+1)` and `* (-1)` respectively but at least for the operator `//` this is just not the case.

However using this quirk of Python was a nice way to learn and explore the operator precedence!
