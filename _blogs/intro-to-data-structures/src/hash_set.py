from hash_map import HashMap

class HashSet:

  def __init__(self):
    self.backing_map = HashMap()

  def __len__(self):
    return len(self.backing_map)

  def put(self, value):
    self.backing_map.put(value, True)

  def contains(self, value):
    return self.backing_map.get(value) is not None
