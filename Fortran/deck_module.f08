module deck_module
  use poker_constants
  use card_module
  implicit none
  ! Define the deck type
  type :: deck
    type(card), dimension(DECK_SIZE) :: cards
    integer :: top = 1  ! Index of the top card in the deck
  end type deck
contains
  ! Subroutine to create a new deck
  subroutine create_deck(d)
    type(deck), intent(out) :: d
    integer :: i, j, k
    k = 1
    do i = 1, 13  ! Loop through ranks
      do j = 1, 4  ! Loop through suits
        d%cards(k) = create_card(i, j)
        k = k + 1
      end do
    end do
    d%top = 1  ! Set the top of the deck to the first card
  end subroutine create_deck

  ! Subroutine to shuffle the deck
  subroutine shuffle_deck(d)
    type(deck), intent(inout) :: d
    integer :: i, j
    type(card) :: temp
    real :: r
    do i = DECK_SIZE, 2, -1  ! Implement Fisher-Yates shuffle
      call random_number(r)
      j = int(r * i) + 1
      temp = d%cards(i)
      d%cards(i) = d%cards(j)
      d%cards(j) = temp
    end do
    d%top = 1  ! Reset the top of the deck after shuffling
  end subroutine shuffle_deck

  ! Function to deal a single card from the deck
  function deal_card(d) result(c)
    type(deck), intent(inout) :: d
    type(card) :: c
    if (d%top > DECK_SIZE) then
      write(*, *) "Error: Deck is empty"
      stop
    end if
    c = d%cards(d%top)
    d%top = d%top + 1  ! Move to the next card
  end function deal_card

  ! Subroutine to deal a hand of cards
  subroutine deal_hand(d, hand)
    type(deck), intent(inout) :: d
    type(card), dimension(MAX_CARDS_IN_HAND), intent(out) :: hand
    integer :: i
    do i = 1, MAX_CARDS_IN_HAND
      hand(i) = deal_card(d)
    end do
  end subroutine deal_hand

  ! Subroutine to print the entire deck
  subroutine print_deck(d)
    type(deck), intent(in) :: d
    integer :: i
    do i = 1, DECK_SIZE
      write(*, '(A3)', advance='no') card_to_string(d%cards(i))
      if (mod(i, 13) == 0) write(*, *)  ! New line after every 13 cards
    end do
    write(*, *)
  end subroutine print_deck

  ! Subroutine to print the remaining cards in the deck
  subroutine print_remaining_deck(d)
    type(deck), intent(in) :: d
    integer :: i
    write(*, *) "*** Here is what remains in the deck... "
    do i = d%top, DECK_SIZE
      write(*, '(A3)', advance='no') card_to_string(d%cards(i))
      if (mod(i - d%top + 1, 13) == 0) write(*, *)  ! New line after every 13 cards
    end do
    write(*, *)
  end subroutine print_remaining_deck
end module deck_module
