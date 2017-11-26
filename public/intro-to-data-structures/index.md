---
title: Intro to Data Structures
layout: default
---

"Data structures" tend to conjure intimidation, but they are very easy to begin to understand.
Understanding data structures helps us to know when we are/aren't using the right tool for our task.


## Array
*contiguous chunk of indexable memory*
```c
// allocating memory for an array of 8 elements in C
int * array = malloc(8 * sizeof(int));
```

The guarantee that elements will reside adjacently allows us to make assumptions about arrays

0. indexing a particular position will be very fast
0. iterating over the array in order will be very fast since computers fetch memory in chunks at a time


## List
*an ordered collection*


## [ArrayList](src/array_list.py)
*an ordered collection backed by a contiguous chunk of indexable memory*

- How would you implement `remove(index)`?
  - set value at index to null then left shift all later values
- How would you implement `contains(value)`?
  - loop through every value and check
  - not guaranteed to be fast!<br />
    In the worst case, you will have to check every element.
- What would happen if you wanted to add many elements?
  - make a new array of double the size then copy every value over


## [LinkedList](src/linked_list.py)
*an ordered collection containing exactly 1 or 0 values and a reference to exactly 1 or 0 other linked lists*

- Why `prepend` instead of `append`?
  - saves us from traversing the entire list
  - guarantees a very fast operation
- How would you implement `remove(index)`?
  - set the `_sucessor` reference of the `index - 1` node to point to `self._successor._successor`
- Which is "better": `ArrayList` or `LinkedList`
  - remove?
    - usually the same speed, though fewer operations with a `LinkedList` because no copying
  - iterate?
    - `ArrayList` is slightly faster since its elements are guaranteed to be stored adjacently in memory
  - contains a value?
    - same as iteration
  - add many elements?
    - `LinkedList` will be slightly quicker since it will never have to resize and copy elements


## Hash function
*a function used to map an object to a set of possible keys, typically `int`s*

The resulting `int` is called a hashcode or hash value.


## [HashMap](src/hash_map.py)
*2-dimensional collection of keys and values, where each value is mapped to its corresponding and unique key based on the key’s hashcode*

Since `HashMap`s are array-based, they are as fast as an `ArrayList` for lookup and addition.
Since they do not guarantee consecutive elements, they have fast removal, unlike an `ArrayList`

- What happens when two values hash to the same value (i.e. `1` and `101`)?
  - the naive implementation just overwrites the previous values, but there are [many strategies to resolve collisions](https://en.wikipedia.org/wiki/Hash_table#Collision_resolution)
- How would you implement
  - `remove(key)`
    - set value at key to null
  - `remove(value)`
    - would need to cycle through all values of the backing array
    - would need to consider how to handle duplicate values since `HashMap`s allow that
- What would happen if we wanted to add many key/value pairs?
  - would need to make a new backing array and re-add/re-hash all key/value pairs

`HashMap`s are not optimized for value-based operations. If you find yourself operating on values in a `HashMap`, consider swapping your key/value association or using an alternative data structure.


## Set
*an unordered collection of unique elements*


## [HashSet](src/hash_set.py)
*an unordered collection of elements that uses the elements hashcode to guarantee fast lookup and addition*

- Why might we not care to implement `get(value)` in a set?
  - if we have the value object already, getting it from a set is not usually useful

Sets are great for collecting unique elements then checking membership. More robust sets also provide interfaces for various [set operations](<https://en.wikipedia.org/wiki/Set_(mathematics)#Basic_operations>).


## Tree
*a one-dimensional collection, which is either empty, or a node containing one value and references to two branches, each of which are trees*


## [Binary Search Tree](src/binary_search_tree.py)
*a tree, whose value is greater than the value of its left branch and less than the value of its right branch, each of with are binary search trees*

- How does `contains(value)` compare to that of the `LinkedList`?
  - eliminating entire sub-trees as you go saves you considerable amount of time
  - algorithm: if `value < self._value` search the left sub-tree, if `value > self._value` search the right sub-tree; otherwise `return !self._empty()`
- How would you implement `remove(value)`?
  - search for `value` then replace it with either the right-most value in the left sub-tree or the left-most element in the right subtree


## [A Recursive Board](src/board.py)
*either empty or a node containing an index, marker, and reference to its previous state, which is also a board*

- How would you implement `undo()`?
  - `return self._parent`
- What are some drawbacks to this implementation?
  - no random access means accessing space by index is not efficient
  - iterating spaces would be less efficient


_Mar 23, 2016_
