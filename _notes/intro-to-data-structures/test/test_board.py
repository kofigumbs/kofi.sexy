from src.board import Board
import unittest

class BoardTest(unittest.TestCase):
  def setUp(self):
    self.subject = Board()

  def test_empty_board_has_size_zero(self):
    self.assertEqual(len(self.subject), 0)
    self.assertEqual(self.subject.get(0), None)

  def test_board_with_one_mark(self):
    self.subject = self.subject.mark(0, "X")
    self.assertEqual(len(self.subject), 1)
    self.assertEqual(self.subject.get(0), "X")

  def test_board_marks_many_values(self):
    self.subject = self.subject.mark(3, "X")
    self.subject = self.subject.mark(1, "X")
    self.subject = self.subject.mark(3, "O")
    self.assertEqual(self.subject.get(1), "X")
    self.assertEqual(self.subject.get(3), "O")
