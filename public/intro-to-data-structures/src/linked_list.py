class LinkedList:

  def __init__(self, _value=None, _successor=None):
    self._value = _value
    self._successor = _successor

  def __len__(self):
    if self._successor is None:
      return 0
    else:
      return 1 + len(self._successor)

  def get(self, index):
    if index == 0:
      return self._value
    else:
      return self._successor.get(index - 1)

  def prepend(self, value):
    return LinkedList(_value=value, _successor=self)
