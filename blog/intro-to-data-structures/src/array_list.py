import array_factory

class ArrayList:

  def __init__(self):
    self._array = array_factory.create(100)
    self.count = 0

  def __len__(self):
    return self.count

  def get(self, index):
    return self._array[index]

  def append(self, value):
    self._array[self.count] = value
    self.count += 1
