module card_module
  use poker_constants
  implicit none
  type :: card
    integer :: rank
    integer :: suit
  end type card
  interface operator(==)
    module procedure card_equal
  end interface
  interface operator(/=)
    module procedure card_not_equal
  end interface
contains
  function create_card(rank, suit) result(new_card)
    integer, intent(in) :: rank, suit
    type(card) :: new_card
    new_card%rank = rank
    new_card%suit = suit
  end function create_card
  function card_to_string(c) result(str)
    type(card), intent(in) :: c
    character(len=3) :: str
    character(len=13), parameter :: ranks = "23456789TJQKA"
    character(len=4), parameter :: suits = "DCHS"
    if (c%rank >= 1 .and. c%rank <= 13 .and. c%suit >= 1 .and. c%suit <= 4) then
      write(str, '(A2,A1)') ranks(c%rank:c%rank), suits(c%suit:c%suit)
    else
      str = "?? "
    end if
  end function card_to_string
  function string_to_card(str) result(c)
    character(len=*), intent(in) :: str
    type(card) :: c
    character(len=13), parameter :: ranks = "23456789TJQKA"
    character(len=4), parameter :: suits = "DCHS"
    integer :: i
    c%rank = 0
    c%suit = 0
    ! Check if the first two characters represent "10"
    if (len_trim(str) == 3 .and. str(1:2) == "10") then
        c%rank = 10
        ! Check the third character for the suit
        do i = 1, 4
            if (str(3:3) == suits(i:i)) then
                c%suit = i
                exit
            end if
        end do
    ! Handle all other cards (length 2)
    else if (len_trim(str) == 2) then
        ! Parse rank for cards 2-9, T, J, Q, K, A
        do i = 1, 13
            if (str(1:1) == ranks(i:i)) then
                c%rank = i
                exit
            end if
        end do
        ! Parse suit
        do i = 1, 4
            if (str(2:2) == suits(i:i)) then
                c%suit = i
                exit
            end if
        end do
    else
        write(*, *) "Invalid card string: ", str
        return
    end if
    ! If no valid rank or suit found, output invalid card
    if (c%rank == 0 .or. c%suit == 0) then
        write(*, *) "Invalid card: ", str
    end if
  end function string_to_card
  function card_equal(c1, c2) result(equal)
    type(card), intent(in) :: c1, c2
    logical :: equal
    equal = (c1%rank == c2%rank) .and. (c1%suit == c2%suit)
  end function card_equal
  function card_not_equal(c1, c2) result(not_equal)
    type(card), intent(in) :: c1, c2
    logical :: not_equal
    not_equal = .not. card_equal(c1, c2)
  end function card_not_equal
  function get_face_value(c) result(face_value)
    type(card), intent(in) :: c
    integer :: face_value
    face_value = c%rank
  end function get_face_value
end module card_module
