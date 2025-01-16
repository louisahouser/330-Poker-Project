module poker_constants
  implicit none

  ! Hand rankings
  integer, parameter :: ROYAL_STRAIGHT_FLUSH = 1
  integer, parameter :: STRAIGHT_FLUSH = 2
  integer, parameter :: FOUR_OF_A_KIND = 3
  integer, parameter :: FULL_HOUSE = 4
  integer, parameter :: FLUSH = 5
  integer, parameter :: STRAIGHT = 6
  integer, parameter :: THREE_OF_A_KIND = 7
  integer, parameter :: TWO_PAIR = 8
  integer, parameter :: PAIR = 9
  integer, parameter :: HIGH_CARD = 10

  ! Suit rankings
  integer, parameter :: DIAMONDS = 1
  integer, parameter :: CLUBS = 2
  integer, parameter :: HEARTS = 3
  integer, parameter :: SPADES = 4

  ! Other constants
  integer, parameter :: MAX_CARDS_IN_HAND = 5
  integer, parameter :: NUM_HANDS = 6
  integer, parameter :: DECK_SIZE = 52

end module poker_constants

