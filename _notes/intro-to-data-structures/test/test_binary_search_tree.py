from src.binary_search_tree import BinarySearchTree
import unittest

class BinarySearchTreeTest(unittest.TestCase):
  def setUp(self):
    self.subject = BinarySearchTree()

  def test_empty_tree_has_size_zero(self):
    self.assertEqual(len(self.subject), 0)

  def test_tree_of_size_one(self):
    self.subject.add(12)
    self.assertEqual(len(self.subject), 1)

  def test_tree_iterates_one_value(self):
    self.subject.add(12)
    iterated = [v for v in self.subject]
    self.assertEqual(iterated, [12])

  def test_tree_iterates_many_values(self):
    self.subject.add(34)
    self.subject.add(56)
    iterated = [v for v in self.subject]
    self.assertEqual(iterated, [34, 56])

  def test_tree_iterates_sorted_values(self):
    self.subject.add(56)
    self.subject.add(12)
    self.subject.add(34)
    iterated = [v for v in self.subject]
    self.assertEqual(iterated, [12, 34, 56])

  def test_tree_contains_value(self):
    self.subject.add(12)
    self.subject.add(34)
    self.assertTrue(self.subject.contains(12))
    self.assertFalse(self.subject.contains(56))
