from src.hash_map import HashMap
import unittest

class BasicHashTest(unittest.TestCase):

  def setUp(self):
    self.subject = HashMap()

  def test_map_has_size_zero(self):
    self.assertEqual(len(self.subject), 0)

  def test_map_of_size_one(self):
    self.subject.put(2, "Two")
    self.assertEqual(len(self.subject), 1)

  def test_map_gets_none_when_key_absent(self):
    self.assertIsNone(self.subject.get(1))

  def test_map_has_one_key_value_pair(self):
    self.subject.put(2, "Two")
    self.assertEqual(self.subject.get(2), "Two")

  def test_map_of_size_two(self):
    self.subject.put(3, "Three")
    self.subject.put(4, "Four")
    self.assertEqual(len(self.subject), 2)

  def test_map_has_two_key_value_pairs(self):
    self.subject.put(5, "Five")
    self.subject.put(6, "Six")
    self.assertEqual(self.subject.get(5), "Five")
    self.assertEqual(self.subject.get(6), "Six")

  def test_put_overwrites_previous(self):
    self.subject.put(7, "Seven")
    self.subject.put(7, "Seventy times seven")
    self.assertEqual(len(self.subject), 1)
    self.assertEqual(self.subject.get(7), "Seventy times seven")

  def test_map_non_int_key(self):
    self.subject.put("eight", "EIGHT")
    self.assertEqual(len(self.subject), 1)
    self.assertEqual(self.subject.get("eight"), "EIGHT")
