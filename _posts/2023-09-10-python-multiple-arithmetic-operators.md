---
title: "Python's arithmetic is weird: 1 +-+-+ 1 == 2"
header:
  image: /assets/images/headers/2023-09-28_pythons-weird-arithmetic.png
  image_description: "An example of Python's weird arithmetic"
  teaser: /assets/images/teasers/2023-09-28_pythons-weird-arithmetic.png
excerpt: Let's explore this strange quirk of the Python language and learn from it.
---

All programming languages have some quirks and strange behavior.
Python is certainly no exception.
I was quite surprised recently when I found out that Python allows multiple `+` and `-` in a row.

```python
>>> 1 +-+-+ 1
2
```

That's right!
This is valid arithmetic in Python.

Now you may think that you can safely stick it into your next commit at work to stump your code reviewer.
Before you do, let me show you that it does not always behave as expected.

# Use as many `+` and `-` together as you want

When using multiple `+` or `-` operators in a row, it's as though the operators are replaced with `* (+1)` and `* (-1)` respectively:

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

Please let me know if you know of another programming language that behaves like this or if you know the purpose for it.
The only use case that I can think of is if you need to ask "help" from a fellow developer to deal with your annoying manager:

```python
my_need = 1 --- +++ --- 5
```

There is always someone familiar with morse code in movies so it might work.

# Using multiple `-` with `//` is weird

In case you don't know, the `//` operator performs a division like `/` but instead returns an integer.

```python
>>> 5 // 2
2
>>> assert 5 // 2 == math.floor(5 / 2)
True
```

Now let's look at this simple calculation using `//`:

```python
>>> 2 + 5 // 2
4
```

Nothing ground breaking here.
Python calculates `5 // 2` before performing the addition.

Let's use the newly discovered feature of Python's arithmetic by replacing `+` with `--`.
What could go wrong?

```python
>>> 2 -- 5 // 2
5
```

What is going on here?
Is Python broken?
Are mathematics failing us?

Let's break this down to understand what is happening:

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
This is why the negative sign is applied to `5` before `5 // 2` is performed.

Now it's all clear and nothing else will surprise us, right?

# Adding a `+` into the mix is even weirder

Now let's add a `+` sign to our previous example because why not!

```python
>>> 2 +-- 5 // 2
4
>>> 2 -+- 5 // 2
5
>>> 2 --+ 5 // 2
5
```

Right now might be a good time to open your Python interpreter and verify that this is for real because you probably don't believe it.

It's as though the `+` doesn't do anything in `-+-` and `--+` compared to using `--` in the previous section.
On the other hand the result is different with `+--`.
Why is that?

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
Most of the time it works as if `+` and `-` could be replaced by `* (+1)` and `* (-1)` respectively but at least for the operator `//` this is just not the case.

However using this quirk of Python was a nice way to learn and explore the operator precedence!

---

*Thank you to [Quinn Blenkinsop](https://github.com/qw-in) for reviewing this post and providing very useful feedback.*
