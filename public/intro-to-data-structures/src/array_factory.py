import numpy

def create(size, kind=object):
  array = numpy.empty(size, dtype=kind)
  for i in range(size):
    array[i] = None
  return array
