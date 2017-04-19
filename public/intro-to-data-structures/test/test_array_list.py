from src.array_list import ArrayList
import unittest

class ArrayListTest(unittest.TestCase):

  def setUp(self):
    self.subject = ArrayList()

  def test_empty_list_has_size_zero(self):
    self.assertEqual(len(self.subject), 0)

  def test_list_of_size_one(self):
    self.subject.append(12)
    self.assertEqual(len(self.subject), 1)

  def test_list_has_one_value(self):
    self.subject.append(12)
    self.assertEqual(self.subject.get(0), 12)

  def test_list_of_size_two(self):
    self.subject.append(34)
    self.subject.append(56)
    self.assertEqual(len(self.subject), 2)

  def test_list_has_two_values(self):
    self.subject.append(78)
    self.subject.append(90)
    self.assertEqual(self.subject.get(0), 78)
    self.assertEqual(self.subject.get(1), 90)
