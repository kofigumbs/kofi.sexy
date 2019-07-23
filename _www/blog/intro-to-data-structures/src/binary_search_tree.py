class BinarySearchTree:
  def __init__(self):
    self._left = None
    self._right = None
    self._value = None

  def __len__(self):
    return 0 if self._empty() else len(self._left) + 1 + len(self._right)

  def __iter__(self):
    if not self._empty():
      for v in self._left:
        yield v
      yield self._value
      for v in self._right:
        yield v

  def _empty(self):
    return self._value is None

  def _fill(self, value):
    self._left = BinarySearchTree()
    self._right = BinarySearchTree()
    self._value = value

  def _branch(self, value):
    return self._left if value < self._value else self._right

  def add(self, value):
    if self._empty():
      self._fill(value)
    else:
      self._branch(value).add(value)

  def contains(self, value):
    if self._empty():
      return False
    elif value == self._value:
      return True
    else:
      return self._branch(value).contains(value)
