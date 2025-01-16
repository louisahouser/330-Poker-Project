program poker_analyzer
  use poker_constants
  use card_module
  use deck_module
  use hand_module
  use game_mode_module
  implicit none
  type(game_mode) :: gm
  logical :: is_test_mode
  character(len=100) :: filename
  integer :: num_args
  character(len=100) :: arg

  ! Initialize random seed for shuffling
  call random_seed()

  ! Check command line arguments
  num_args = command_argument_count()
  if (num_args == 0) then
    ! No arguments: run in normal mode
    is_test_mode = .false.
    write(*, *) "*** POKER HAND ANALYZER ***"
    write(*, *)
  else if (num_args == 1) then
    ! One argument: run in test mode with provided file
    is_test_mode = .true.
    call get_command_argument(1, filename)
  else
    ! Invalid number of arguments
    write(*, *) "Usage: ./poker_analyzer [filename]"
    stop
  end if

  ! Initialize game mode
  if (is_test_mode) then
    call initialize_game_mode(gm, is_test_mode, filename)
  else
    call initialize_game_mode(gm, is_test_mode)
  end if

  ! Run the game
  call run_game(gm)
end program poker_analyzer
