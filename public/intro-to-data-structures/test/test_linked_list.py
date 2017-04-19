from src.linked_list import LinkedList
import unittest

class LinkedListTest(unittest.TestCase):

  def setUp(self):
    self.subject = LinkedList()

  def test_empty_list_has_size_zero(self):
    self.assertEqual(len(self.subject), 0)

  def test_list_of_size_one(self):
    self.subject = self.subject.prepend(12)
    self.assertEqual(len(self.subject), 1)

  def test_list_has_one_value(self):
    self.subject = self.subject.prepend(12)
    self.assertEqual(self.subject.get(0), 12)

  def test_list_of_size_two(self):
    self.subject = self.subject.prepend(34)
    self.subject = self.subject.prepend(56)
    self.assertEqual(len(self.subject), 2)

  def test_list_has_two_values(self):
    self.subject = self.subject.prepend(78)
    self.subject = self.subject.prepend(90)
    self.assertEqual(self.subject.get(0), 90)
    self.assertEqual(self.subject.get(1), 78)
