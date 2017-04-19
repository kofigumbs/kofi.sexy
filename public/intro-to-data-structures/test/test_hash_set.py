from src.hash_set import HashSet
import unittest

class HashSetTest(unittest.TestCase):
  def setUp(self):
    self.subject = HashSet()

  def test_set_has_size_zero(self):
    self.assertEqual(len(self.subject), 0)

  def test_set_of_size_one(self):
    self.subject.put("Two")
    self.assertEqual(len(self.subject), 1)

  def test_set_does_not_contain_absent_key(self):
    self.assertFalse(self.subject.contains("One"))

  def test_set_has_one_value(self):
    self.subject.put("Two")
    self.assertTrue(self.subject.contains("Two"))

  def test_set_of_size_two(self):
    self.subject.put("Three")
    self.subject.put("Four")
    self.assertEqual(len(self.subject), 2)

  def test_set_has_two_key_value_pairs(self):
    self.subject.put("Five")
    self.subject.put("Six")
    self.assertTrue(self.subject.contains("Five"))
    self.assertTrue(self.subject.contains("Six"))

  def test_set_does_not_contain_duplicates(self):
    self.subject.put("Seven")
    self.subject.put("Seven")
    self.subject.put("Seven")
    self.assertEqual(len(self.subject), 1)
    self.assertTrue(self.subject.contains("Seven"))

  def test_set_non_int_key(self):
    self.subject.put("EIGHT")
    self.assertEqual(len(self.subject), 1)
    self.assertTrue(self.subject.contains("EIGHT"))
