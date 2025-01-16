module game_mode_module
  use poker_constants
  use card_module
  use deck_module
  use hand_module
  implicit none

  ! Define the game_mode type
  type :: game_mode
    logical :: is_test_mode
    character(len=100) :: filename
    type(hand), dimension(NUM_HANDS) :: hands
  end type game_mode

contains

  ! Subroutine to initialize the game mode
  subroutine initialize_game_mode(gm, is_test_mode, filename)
    type(game_mode), intent(out) :: gm
    logical, intent(in) :: is_test_mode
    character(len=*), intent(in), optional :: filename

    gm%is_test_mode = is_test_mode
    if (present(filename)) then
      gm%filename = filename
    else
      gm%filename = ""
    end if
  end subroutine initialize_game_mode

  ! Main subroutine to run the game
  subroutine run_game(gm)
    type(game_mode), intent(inout) :: gm
    type(deck) :: d

    if (gm%is_test_mode) then
      call read_test_deck(gm)
    else
      call create_deck(d)
      call shuffle_deck(d)
      call print_deck(d)
      call deal_hands(d, gm%hands)
      call print_remaining_deck(d)
    end if

    call evaluate_hands(gm%hands)
    call rank_hands(gm%hands)
    call print_results(gm%hands)
  end subroutine run_game

  ! Subroutine to read a test deck from a file
  subroutine read_test_deck(gm)
    type(game_mode), intent(inout) :: gm
    integer :: i, j, ios
    character(len=50) :: line
    character(len=3) :: card_str

    ! Open the test deck file
    open(unit=10, file=trim(gm%filename), status='old', action='read', iostat=ios)
    if (ios /= 0) then
      write(*, *) "Error opening file: ", trim(gm%filename)
      stop
    end if

    write(*, *) "*** USING TEST DECK ***"
    write(*, *) "*** File: ", trim(gm%filename)
    write(*, *)

    ! Read and process each hand
    do i = 1, NUM_HANDS
      read(10, '(A)', iostat=ios) line
      if (ios /= 0) then
        write(*, *) "Error reading line from file"
        close(10)
        stop
      endif
      do j = 1, MAX_CARDS_IN_HAND
        read(line, *, iostat=ios) card_str
        if(ios /= 0) then
                write(*, *) "Error parsing card from line"
                close(10)
                stop
        endif
        card_str = adjustl(trim(card_str))
        if (len_trim(card_str) < 2 .or. len_trim(card_str) > 3) then
                write(*, *) "Invalid card format: ", card_str
                close(10)
                stop
        endif
        gm%hands(i)%cards(j) = string_to_card(card_str)
        line = line(index(line, ',') + 1:)
      end do
      call sort_hand(gm%hands(i))
    end do

    close(10)

    ! Print the hands
    write(*, *) "*** Here are the six hands..."
    do i = 1, NUM_HANDS
      call print_hand(gm%hands(i))
    end do
    write(*, *)
  end subroutine read_test_deck

  ! Subroutine to deal hands from a deck
  subroutine deal_hands(d, hands)
    type(deck), intent(inout) :: d
    type(hand), dimension(NUM_HANDS), intent(out) :: hands
    integer :: i

    do i = 1, NUM_HANDS
      call deal_hand(d, hands(i)%cards)
      call sort_hand(hands(i))
    end do

    ! Print the hands
    write(*, *) "*** Here are the six hands..."
    do i = 1, NUM_HANDS
      call print_hand(hands(i))
    end do
    write(*, *)
  end subroutine deal_hands

  ! Subroutine to evaluate all hands
  subroutine evaluate_hands(hands)
    type(hand), dimension(NUM_HANDS), intent(inout) :: hands
    integer :: i

    do i = 1, NUM_HANDS
      call sort_hand(hands(i))
      call evaluate_hand(hands(i))
    end do
  end subroutine evaluate_hands

  ! Subroutine to rank all hands
  subroutine rank_hands(hands)
    type(hand), dimension(NUM_HANDS), intent(inout) :: hands
    integer :: i, j
    type(hand) :: temp_hand

    do i = 1, NUM_HANDS - 1
      do j = i + 1, NUM_HANDS
        if (hands(j)%rank < hands(i)%rank .or. &
            (hands(j)%rank == hands(i)%rank .and. compare_hands(hands(j), hands(i)) > 0)) then
          temp_hand = hands(i)
          hands(i) = hands(j)
          hands(j) = temp_hand
        end if
      end do
    end do
  end subroutine rank_hands

  ! Function to compare two hands
  function compare_hands(h1, h2) result(comp)
    type(hand), intent(in) :: h1, h2
    integer :: comp, i

    do i = 5, 1, -1
      if (h1%cards(i)%rank /= h2%cards(i)%rank) then
        comp = h1%cards(i)%rank - h2%cards(i)%rank
        return
      end if
    end do
    comp = h1%cards(1)%suit - h2%cards(1)%suit
  end function compare_hands

  ! Subroutine to print the final results
  subroutine print_results(hands)
    type(hand), dimension(NUM_HANDS), intent(in) :: hands
    integer :: i

    write(*, *) "--- WINNING HAND ORDER ---"
    do i = 1, NUM_HANDS
      call print_hand(hands(i))
    end do
    write(*, *)
  end subroutine print_results

end module game_mode_module
