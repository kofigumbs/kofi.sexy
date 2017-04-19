import array_factory

class HashMap:

  def __init__(self):
    self._table = array_factory.create(100)
    self._count = 0

  def __len__(self):
    return self._count

  def _hash_for(self, key):
    return hash(key) % len(self._table)

  def _set(self, key, value):
    self._table[self._hash_for(key)] = value

  def get(self, key):
    return self._table[self._hash_for(key)]

  def put(self, key, value):
    old_value = self.get(key)
    self._set(key, value)
    if old_value is None:
      self._count += 1
