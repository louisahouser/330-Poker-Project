module hand_module
  use poker_constants
  use card_module
  implicit none

  ! Define the hand type
  type :: hand
    type(card), dimension(MAX_CARDS_IN_HAND) :: cards
    integer :: rank
    character(len=25) :: name
  end type hand

contains

  ! Subroutine to evaluate the rank of a hand
  subroutine evaluate_hand(h)
    type(hand), intent(inout) :: h

    ! Check for different hand rankings from highest to lowest
    if (is_royal_flush(h)) then
      h%rank = ROYAL_STRAIGHT_FLUSH
      h%name = "Royal Straight Flush"
    else if (is_straight_flush(h)) then
      h%rank = STRAIGHT_FLUSH
      h%name = "Straight Flush"
    else if (is_four_of_a_kind(h)) then
      h%rank = FOUR_OF_A_KIND
      h%name = "Four of a Kind"
    else if (is_full_house(h)) then
      h%rank = FULL_HOUSE
      h%name = "Full House"
    else if (is_flush(h)) then
      h%rank = FLUSH
      h%name = "Flush"
    else if (is_straight(h)) then
      h%rank = STRAIGHT
      h%name = "Straight"
    else if (is_three_of_a_kind(h)) then
      h%rank = THREE_OF_A_KIND
      h%name = "Three of a Kind"
    else if (is_two_pair(h)) then
      h%rank = TWO_PAIR
      h%name = "Two Pair"
    else if (is_pair(h)) then
      h%rank = PAIR
      h%name = "Pair"
    else
      h%rank = HIGH_CARD
      h%name = "High Card"
    end if
  end subroutine evaluate_hand

  ! Function to check if a hand is a straight
  function is_straight(h) result(straight)
    type(hand), intent(in) :: h
    logical :: straight
    integer :: i, prev_rank

    straight = .true.
    prev_rank = h%cards(5)%rank  ! Start from the highest card
    do i = 4, 1, -1
       if (h%cards(i)%rank /= prev_rank - 1) then
          ! Check for Ace-low straight (A, 2, 3, 4, 5)
          if (.not. (i == 1 .and. h%cards(5)%rank == 14 .and. h%cards(1)%rank == 2)) then
             straight = .false.
             return
          end if
       end if
       prev_rank = h%cards(i)%rank
    end do
  end function is_straight

  ! Function to check if a hand is a royal flush
  function is_royal_flush(h) result(royal_flush)
    type(hand), intent(in) :: h
    logical :: royal_flush

    royal_flush = is_flush(h) .and. is_straight(h) .and. h%cards(5)%rank == 14
  end function is_royal_flush

  ! Function to check if a hand is a straight flush
  function is_straight_flush(h) result(straight_flush)
    type(hand), intent(in) :: h
    logical :: straight_flush

    straight_flush = is_flush(h) .and. is_straight(h)
  end function is_straight_flush

  ! Function to check if a hand has four of a kind
  function is_four_of_a_kind(h) result(four_of_a_kind)
    type(hand), intent(in) :: h
    logical :: four_of_a_kind
    integer :: i, count

    do i = 1, 2
      count = count_rank(h, h%cards(i)%rank)
      if (count == 4) then
        four_of_a_kind = .true.
        return
      end if
    end do
    four_of_a_kind = .false.
  end function is_four_of_a_kind

  ! Function to check if a hand is a full house
  function is_full_house(h) result(full_house)
    type(hand), intent(in) :: h
    logical :: full_house
    integer :: i, three_count, pair_count

    three_count = 0
    pair_count = 0
    do i = 1, 5
      if (count_rank(h, h%cards(i)%rank) == 3) three_count = three_count + 1
      if (count_rank(h, h%cards(i)%rank) == 2) pair_count = pair_count + 1
    end do
    full_house = (three_count == 1 .and. pair_count == 1)
  end function is_full_house

  ! Function to check if a hand is a flush
  function is_flush(h) result(flush)
    type(hand), intent(in) :: h
    logical :: flush
    integer :: i

    flush = .true.
    do i = 2, 5
      if (h%cards(i)%suit /= h%cards(1)%suit) then
        flush = .false.
        return
      end if
    end do
  end function is_flush

  ! Function to check if a hand has three of a kind
  function is_three_of_a_kind(h) result(three_of_a_kind)
    type(hand), intent(in) :: h
    logical :: three_of_a_kind
    integer :: i

    do i = 1, 3
      if (count_rank(h, h%cards(i)%rank) == 3) then
        three_of_a_kind = .true.
        return
      end if
    end do
    three_of_a_kind = .false.
  end function is_three_of_a_kind

  ! Function to check if a hand has two pairs
  function is_two_pair(h) result(two_pair)
    type(hand), intent(in) :: h
    logical :: two_pair
    integer :: i, pair_count, first_pair_rank

    pair_count = 0
    first_pair_rank = 0
    two_pair = .false.

    do i = 1, 4
       if (h%cards(i)%rank == h%cards(i+1)%rank) then
          if (pair_count == 0) then
             pair_count = 1
             first_pair_rank = h%cards(i)%rank
          else if(h%cards(i)%rank /= first_pair_rank) then
             two_pair = .true.
             return
          end if
       end if
    end do
    two_pair = (pair_count == 2)
  end function is_two_pair

  ! Function to check if a hand has a pair
  function is_pair(h) result(pair)
    type(hand), intent(in) :: h
    logical :: pair
    integer :: i

    pair = .false.
    do i = 1, 4
      if (h%cards(i)%rank == h%cards(i+1)%rank) then
        pair = .true.
        return
      end if
    end do
    pair = .false.
  end function is_pair

  ! Function to count occurrences of a specific rank in a hand
  function count_rank(h, rank) result(count)
    type(hand), intent(in) :: h
    integer, intent(in) :: rank
    integer :: count, i

    count = 0
    do i = 1, 5
      if (h%cards(i)%rank == rank) count = count + 1
    end do
  end function count_rank

  ! Subroutine to sort a hand by rank (descending order)
  subroutine sort_hand(h)
    type(hand), intent(inout) :: h
    integer :: i, j
    type(card) :: temp

    do i = 1, 4
      do j = i+1, 5
        if (h%cards(j)%rank > h%cards(i)%rank) then
          temp = h%cards(i)
          h%cards(i) = h%cards(j)
          h%cards(j) = temp
        end if
      end do
    end do
  end subroutine sort_hand

  ! Subroutine to print a hand
  subroutine print_hand(h)
    type(hand), intent(in) :: h
    integer :: i
    character(len=3) :: card_str

    do i = 1, MAX_CARDS_IN_HAND
      card_str = card_to_string(h%cards(i))
      write(*, '(A3)', advance='no') card_str
    end do
    write(*, '(A, A)') " - ", trim(h%name)
  end subroutine print_hand

end module hand_module
