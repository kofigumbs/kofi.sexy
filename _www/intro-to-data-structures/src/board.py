class Board:
  def __init__(self, _position=None, _value=None, _parent=None):
    self._position = _position
    self._value = _value
    self._parent = _parent

  def __len__(self):
    return 0 if self._empty() else 1 + len(self._parent)

  def _empty(self):
    return self._parent is None

  def mark(self, position, value):
    return Board(position, value, self)

  def get(self, position):
    if self._empty():
      return None
    elif position == self._position:
      return self._value
    else:
      return self._parent.get(position)
