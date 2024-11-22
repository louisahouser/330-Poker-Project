#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw(shuffle max);
use Data::Dumper;

###### HELPER FUNCTIONS ####### -------------------------------------

### helper function to convert face cards to numerical values
sub face_to_value{

    my ($face) = @_;    # gets first parameter from @_ array
    # remove any whitespaces
    $face =~ s/^\s+|\s+$//g;
    # compared to def face_to_value(face)
    return 10 if $face eq "10";
    return 11 if $face eq "J";
    return 12 if $face eq "Q";
    return 13 if $face eq "K";
    return 14 if $face eq "A";
    return int($face);

#    $face =~ s/[^0-9]//g;
#    return int($face) if $face =~ /^\d+$/;
#    return 0;
}

### helper function to rank suits
sub rank_suits {
    my ($suit) = @_;    # gets first parameter
    # Assigns numerical values to suits for comparison purposes
    return 1 if $suit eq 'D';
    return 2 if $suit eq 'C';
    return 3 if $suit eq 'H';
    return 4 if $suit eq 'S';
    return 0;
}

###### GLOBAL VARIABLES ###### --------------------------------------
# Boolean flags for different poker hands
our $RSF = 0;
our $SF = 0;
our $FOAK = 0;
our $FH = 0;
our $FLUSH = 0;
our $STRAIGHT = 0;
our $TOAK = 0;
our $TP = 0;
our $PAIR = 0;
our $HC = 0;

###### CARD CLASS ####### -------------------------------------------
package Card;

    sub new {
        my ($class, $suit, $face) = @_; # gets three parameters
        # this makes me giggle
            ### i looked into background and its so funny
            # changing a hash(which is "regular") into something 
            # more "special", an object
        # the first argument is the reference to be blessed
        # second arg is the class name to bless it into 
        return bless {
            suit => $suit // "",
            face => $face //"",
        }, $class;
    }

    sub to_string {
        my ($self) = @_;     # gets first parameter
        return $self->{face} . $self->{suit};
    }


###### PLAYER CLASS ####### ----------------------------------------
package Player;
    sub new {
        my ($class, $hand, $word_list, $order) = @_; # 4 parameters
        # Initialize player with empty hash maps for counting suits and ranks
        my $self = {
            hand => $hand // "",
            word_list => $word_list // [],
            order => $order // 0,
            suit_count => {},
            rank_count => {},
        };        
        bless $self, $class; #hehe
        $self->convert_hand($hand) if $hand;
        return $self;
    }

    sub convert_hand {
        my ($self, $cards) = @_;

        ## reset globals
        $main::RSF = $main::SF = $main::FOAK = $main::FH = $main::FLUSH
        = $main::STRAIGHT = $main::TOAK = $main::TP = $main::PAIR 
        = $main::HC = 0; 

        # splits on whitespaces
            # \s+ is a 'regex' for one or ore whitespace chars
        my @card_array = split(/[,\s]+/, $cards);

        # loop through each card from the array
        foreach my $word (@card_array) {
            # adds the card to the word_list array
            #$word =~ s/\s+//g;
            $word =~ s/^\s+|\s+$//g;

            push @{$self->{word_list}}, $word;

            # gets just the face and just the suit
            my $face_string = substr($word, 0, -1);    # gets all but last char
            my $suit_char = substr($word, -1); # gets last char

            # Increment counters for both suit and rank frequencies
            $self->{suit_count}{$suit_char}++;
            my $face_val = main::face_to_value($face_string); 
            $self->{rank_count}{$face_val}++; ## count each rank
        }
        
        $self->evaluate_hand();    
    }

    sub evaluate_hand {
        my ($self) = @_;
        # Check for hands in descending order of value
        if ($self->is_flush() && $self->is_straight() && $self->is_royal()) {
            $main::RSF = 1;
        }
        #### WHY NOT INCLUDE THE E??? 
        elsif($self->is_flush() && $self->is_straight()){
            $main::SF = 1;
        }elsif($self->is_flush()){
            $main::FLUSH = 1;
        }elsif($self->is_straight()){
            $main::STRAIGHT = 1;
        }

        $self->find_pairs();
    }

    sub is_flush{

        my ($self) = @_;

        # for each count in suit_count.values()
            # %{$self->{suit_count}} is a hash reference
            # %{---} dereferences
            # values before it gets just the numbers not the suits
        foreach my $count (values %{$self->{suit_count}}) {
            return 1 if $count == 5;
        }

        return 0;

    }

    sub is_straight {

        my($self) = @_;

        # keys gets rank numbers from dereferenced hash reference
            # sort { $a <=> $b }
                ## perls numeric comparison operator
                ## <=> returns -1, 0, or 1 depending on if
                ## $a is less than, equal, or greater than $b
        # compared to rankings = sorted(self.rank_count.keys())
        my @rankings = sort { $a <=> $b } keys %{$self->{rank_count}};
        if(@rankings == 5){
            # Special case: Ace-low straight (A,2,3,4,5)
            return 1 if join(",", @rankings) eq "2,3,4,5,14";

            for (my $i = 1; $i < @rankings; $i++) {
                # check for ace-low straight
                return 0 if $rankings[$i] != $rankings[$i-1] + 1;
            }
            return 1;
        }
        return 0;
    }

    sub is_royal {
        
        my($self) = @_;

        #10..14 is the range to check through (ace through 10)
            # returns false if any value is missing
            # returns true ONLY if all values are present
        for my $val (10..14) {
            return 0 unless $self->{rank_count}{$val};
        }
        return 1;

    }

    sub find_pairs {

        my ($self) = @_;
        my $pair_count = 0;

        ### goes and looks for FOAK, TOAK, and finds how many pairs there are
        foreach my $rank (values %{$self->{rank_count}}) {
            if ($rank == 4) {
                $main::FOAK = 1;
            }elsif ($rank == 3) {
                $main::TOAK = 1;
            }elsif ($rank == 2) {
                $pair_count++;
            }
        }

        ### if pair_count == 2, then TP = true, else its a pair
        if ($pair_count == 2) {
            $main::TP = 1;
        } elsif ($pair_count == 1) {
            $main::PAIR = 1;
        }

        ### if both TOAK and pair, then FULL HOUSE!!
        if($main::TOAK && $main::PAIR){
            $main::FH = 1;
        } elsif (!$main::PAIR && !$main::TOAK && !$main::FOAK) {
            $main::HC = 1;
        }
    }

    sub set_final_scores {
        my ($self) = @_;

        ### check for each global var and set their hand and order
        if($main::RSF){
            $self->{hand} = "Royal Straight Flush";
            $self->{order} = 1;
            $main::RSF = 0;
        }elsif($main::SF){
            $self->{hand} = "Straight Flush";
            $self->{order} = 2;
            $main::SF = 0;
        }elsif($main::FOAK){
            $self->{hand} = "Four of a Kind";
            $self->{order} = 3;
            $main::FOAK = 0;
        }elsif($main::FH){
            $self->{hand} = "Full House";
            $self->{order} = 4;
            $main::FH = 0;
        }elsif($main::FLUSH){
            $self->{hand} = "Flush";
            $self->{order} = 5;
            $main::FLUSH = 0;    
        }elsif($main::STRAIGHT){
            $self->{hand} = "Straight";
            $self->{order} = 6;
            $main::STRAIGHT = 0;    
        }elsif($main::TOAK){
            $self->{hand} = "Three of a Kind";
            $self->{order} = 7;
            $main::TOAK = 0;    
        }elsif($main::TP){
            $self->{hand} = "Two Pair";
            $self->{order} = 8;
            $main::TP = 0;    
        }elsif($main::PAIR){
            $self->{hand} = "Pair";
            $self->{order} = 9;
            $main::PAIR = 0;    
        }else {
            $self->{hand} = "High Card";
            $self->{order} = 10;
            $main::HC = 0;
        }
    }

    #self explanatory
    sub get_order{$_[0]->{order}}
    sub get_hand{$_[0]->{hand}}
    sub get_word_list{$_[0]->{word_list}}


package Deck;

    # constructor that creates a deck of cards of card objects
    sub new {
        my ($class, $test) = @_;
        # Initialize deck properties including dimensions and card arrays
        my $self = {
            rows => 4,
            cols => 13,
            deck_array => [],
            delt_cards => [""] x 6,
            result => [],
            suits => ["D", "C", "H", "S"],
            faces => ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"],
        };
        bless $self, $class; ## hehe
    
        unless ($test){
            # Create the standard 52-card deck unless in test mode
            for my $i (0..$self->{rows}-1){
                for my $j (0..$self->{cols}-1){
                    $self->{deck_array}[$i][$j] = Card->new(
                        $self->{suits}[$i],
                        $self->{faces}[$j]
                    );
                }
            }
        }
        
        return $self;    

    }

    sub shuffle_deck {
        my ($self) = @_;
        # Convert 2D array to 1D for shuffling
        my @flat_deck;
        for my $i (0..$self->{rows}-1){
            for my $j (0..$self->{cols}-1){
                push @flat_deck, $self->{deck_array}[$i][$j];
            }
        }

        ## SHUFFLE flattened deck array
        @flat_deck = List::Util::shuffle(@flat_deck);

        ## revert flattened to the og array that has now been shuffled
        my $loc = 0;
        for my $i (0..$self->{rows}-1){
            for my $j (0..$self->{cols}-1){
                $self->{deck_array}[$i][$j] = $flat_deck[$loc++];
            }
        }
    }

    sub deal_hands {
        my($self) = @_;
        # Initialize array for 6 hands
        my @hands = ("") x 6;
        my $count = 0;

        # Deal first 30 cards (5 cards to each of 6 hands)
        for my $i (0..$self->{rows}-1){
            for my $j (0..$self->{cols}-1){
                if($count < 30){
                    my $hand_index = $count % 6;
                    $hands[$hand_index] .= $self->{deck_array}[$i][$j]->to_string() . " ";
                    $count++;
                }
            }
        }

        $self->{delt_cards} = \@hands;

    }

    sub print_hands {
        my ($self) = @_;
        print "*** Here are the six hands...\n";
        foreach my $hand (@{$self->{delt_cards}}){
            print "$hand\n";
        }
    }

    sub rank_hands {
        my ($self, $arr) = @_;
        # Create Player objects for each hand and evaluate them
        for my $i (0..5){
            my $current_card = Player->new($arr->[$i], [], 0);
            $current_card->set_final_scores();
            push @{$self->{result}}, $current_card;
        }
    }

    sub tie_breakers {
        my ($self) = @_;
        # Compare each hand with every other hand for potential ties
        for my $i (0..5){
            for my $j ($i+1..5){
                if ($self->{result}[$i]->get_order() == $self->{result}[$j]->get_order()) {
                    my $should_swap = 0;

                    # Handle tie breakers based on hand type
                    if ($self->{result}[$i]->get_hand() =~ /^(Straight Flush|Flush|Royal Straight Flush|Straight|High Card)$/){
                        $should_swap = $self->get_high_card($self->{result}[$i]) < $self->get_high_card($self->{result}[$j]);
                    }elsif($self->{result}[$i]->get_hand() eq "Four of a Kind"){
                        my $rank_i = $self->get_foak_rank($self->{result}[$i]);
                        my $rank_j = $self->get_foak_rank($self->{result}[$j]);
                        $should_swap = $rank_i < $rank_j || ($rank_i == $rank_j && $self->get_kicker($self->{result}[$i]) < $self->get_kicker($self->{result}[$j]));
                        
                    }elsif($self->{result}[$i]->get_hand() eq "Full House"){
                        $should_swap = $self->get_toak_rank($self->{result}[$i]) < $self->get_toak_rank($self->{result}[$j]);
                    }elsif($self->{result}[$i]->get_hand() eq "Three of a Kind"){
my $rank_i = $self->get_toak_rank($self->{result}[$i]);
                        my $rank_j = $self->get_toak_rank($self->{result}[$j]);
                        $should_swap = $rank_i < $rank_j || ($rank_i == $rank_j && $self->get_kicker($self->{result}[$i]) < $self->get_kicker($self->{result}[$j]));
                    }elsif ($self->{result}[$i]->get_hand() eq "Two Pair") {
                        my $ranks_i = $self->get_two_pair_ranks($self->{result}[$i]);
                        my $ranks_j = $self->get_two_pair_ranks($self->{result}[$j]);
                        # Compare higher pair first
                        if ($ranks_i->[0] != $ranks_j->[0]) {
                            $should_swap = $ranks_i->[0] < $ranks_j->[0];
                        }
                        # If higher pairs are equal, compare lower pairs
                        elsif ($ranks_i->[1] != $ranks_j->[1]) {
                            $should_swap = $ranks_i->[1] < $ranks_j->[1];
                        }
                        # If both pairs are equal, compare kickers
                        else {
                            $should_swap = $self->get_kicker($self->{result}[$i]) < 
                                     $self->get_kicker($self->{result}[$j]);
                        }
                    }elsif ($self->{result}[$i]->get_hand() eq "Pair") {
                        my $rank_i = $self->get_pair_rank($self->{result}[$i]);
                        my $rank_j = $self->get_pair_rank($self->{result}[$j]);
                        if ($rank_i != $rank_j) {
                            $should_swap = $rank_i < $rank_j;
                        }
                        else {
                            # Compare kickers in descending order for pairs
                            my @kickers_i = $self->get_kickers($self->{result}[$i]);
                            my @kickers_j = $self->get_kickers($self->{result}[$j]);
                            for my $k (0..2) {  # Compare up to 3 kickers
                                if ($kickers_i[$k] != $kickers_j[$k]) {
                                    $should_swap = $kickers_i[$k] < $kickers_j[$k];
                                    last;
                                }
                            }
                        }
                    }

                    # Perform the swap if necessary
                    if($should_swap){
                        my $temp = $self->{result}[$i];
                        $self->{result}[$i] = $self->{result}[$j];
                        $self->{result}[$j] = $temp;
                    }
                }
            }
        }
    } 

###### TIEBREAKER HELPER FUNCS ###### -----------------------------------------------------------------------

    sub get_pair_rank{
        my ($self, $player) = @_;
        # Count occurrences of each face value
        my %count_map;
        foreach my $card (@{$player->get_word_list()}){
            my $face = substr($card, 0, -1);
            $count_map{$face}++;
        }
        # Return the rank of the pair found
        foreach my $face (keys %count_map){
            return main::face_to_value($face) if $count_map{$face} == 2;
        }

        return -1;
    }    

    sub get_kickers{
        my ($self, $player) = @_;
        # Count occurrences of each face value
        my %count_map;
        my @kickers;
        foreach my $card (@{$player->get_word_list()}){
            my $face = substr($card, 0, -1);
            $count_map{$face}++;
        }

        # Collect all single cards (kickers)
        foreach my $card (@{$player->get_word_list()}){
            my $face = substr($card, 0, -1);
            push @kickers, main::face_to_value($face) if $count_map{$face} == 1;
        }
        
        return sort {$b <=> $a} @kickers; # return kickers in descending order
    }

    sub get_high_card{
        my ($self, $player) = @_;
        my $highest = -1;
        # Find the highest value card in the hand
        foreach my $card (@{$player->get_word_list()}) {
            my $face = substr($card, 0, -1);
            my $val = main::face_to_value($face);
            $highest = $val if $val > $highest;
        }

        return $highest
    }

    sub get_kicker{
        my ($self, $player) = @_;
        my %count_map;
        # count how many times each face value happens
        foreach my $card (@{$player->get_word_list()}){
            my $face = substr($card, 0, -1);
            $count_map{$face}++;
        }

        # return val of first card that only appears once
        foreach my $card (@{$player->get_word_list()}){
            my $face = substr($card, 0, -1);
            if ($count_map{$face} == 1){
                return main::face_to_value($face);
            }
        }
    
        return -1;
    }

    sub get_foak_rank{
        my ($self, $player) = @_;
        my %count_map;
    
        foreach my $card (@{$player->get_word_list()}){
            my $face = substr($card, 0, -1);
            $count_map{$face}++;
        }

        # Return the rank of any four-of-a-kind found
        foreach my $face (keys %count_map){
            return main::face_to_value($face) if $count_map{$face} == 4;
        }
    }


    sub get_toak_rank{
        my ($self, $player) = @_;
        my %count_map;
    
        foreach my $card (@{$player->get_word_list()}){
            my $face = substr($card, 0, -1);
            $count_map{$face}++;
        }

        # Return the rank of any three-of-a-kind found
        foreach my $face (keys %count_map){
            return main::face_to_value($face) if $count_map{$face} == 3;
        }
    }

    sub get_two_pair_ranks{
    
        my ($self, $player) = @_;
        my %count_map;
        my @pairs;

        # count occurrences of each face value    
        foreach my $card (@{$player->get_word_list()}){
            my $face = substr($card, 0, -1);
            $count_map{$face}++;
        }

        # collect all pairs
        foreach my $face (keys %count_map) {
            if ($count_map{$face} == 2) {
                push @pairs, main::face_to_value($face);
            }
        }

        # sort pairs in descending order for comparison
        @pairs = sort{$b <=> $a} @pairs;

        return \@pairs;
    }

    sub get_kicker_suit{

        my ($self, $player) = @_;
        my %count_map;
    
        foreach my $card (@{$player->get_word_list()}){
            my $face = substr($card, 0, -1);
            $count_map{$face}++;
        }

        # Return suit of first single card found
        foreach my $card (@{$player->get_word_list()}){
            my $face = substr($card, 0, -1);
            return substr($card, -1) if $count_map{$face} == 1;
        }

        return ' ';
    }
    
    sub get_high_card_nip{
        
        my ($self, $player) = @_;
        my %count_map;
        my $high_card = -1;
        my $high_suit = ' ';
    
        foreach my $card (@{$player->get_word_list()}){
            my $face = substr($card, 0, -1);
            $count_map{$face}++;
        }

        # Find highest single card and its suit
        foreach my $card (@{$player->get_word_list()}){
            my $face = substr($card, 0, -1);
            my $suit = substr($card, -1);
            if($count_map{$face} == 1){
                my $face_value = main::face_to_value($face);
                if($face_value > $high_card){
                    $high_card = $face_value;
                    $high_suit = $suit;
                }
            }
        }

        return $high_suit;
    }

    sub sort_order{
        my ($self) = @_;
        # Sort hands by their rank order (1-10)
        @{$self->{result}} = sort{$a->get_order() <=> $b->get_order()} @{$self->{result}};
    }

    sub print_result{
        my($self) = @_;
        $self->sort_order();
        $self->tie_breakers();
        print "\n--- WINNING HAND ORDER ---\n";
        foreach my $player (@{$self->{result}}){
            print join(" ", @{$player->get_word_list()}), " - ", $player->get_hand(), "\n";
        }
        print "\n";
    }

    sub retrieve_card{
        my ($self) = @_;
        print "*** Shuffled 52 card deck: \n";
        # Print entire deck in 4x13 grid format
        for my $k (0..$self->{rows}-1) {
            for my $m (0..$self->{cols}-1){
                print $self->{deck_array}[$k][$m]->to_string(), " ";
            }
            print "\n";
        }
    }

    sub remaining_deck{
        my ($self) = @_;
        print "*** Here is what remains in the deck... \n";
        my $count = 0; 
        # Print cards after index 30 (remaining after dealing)
        for my $k (0..$self->{rows}-1){
            for my $m (0..$self->{cols}-1){
                if($count >= 30){
                    print $self->{deck_array}[$k][$m]->to_string(), " ";
                }
                $count++;
            }
        }

        print "\n";
        $self->rank_hands($self->{delt_cards});
    }




###### MAIN CLASS ###### ----------------------------------------------------------------------
package main;

sub main{

    my (@args) = @_;

    if (!@args) {
        print "*** POKER HAND ANALYZER ***\n\n";

        my $deck = Deck->new(0);
        $deck->shuffle_deck();
        $deck->retrieve_card();
        $deck->deal_hands();
        print "\n";
        $deck->print_hands();
        print "\n";
        $deck->remaining_deck();
        $deck->print_result();
    } elsif(@args == 1){
        print " *** P O K E R   H A N D   A N A L Y Z E R ***\n\n";
        print "*** USING TEST DECK ***\n\n";

        my $filename = $args[0];
        print "*** File: $filename\n";

        # Track seen cards to prevent duplicates
        my %cards_in_deck;

        # read in test hands
        #     HEHE OR DIE
        open(my $fh, '<', $filename) or die "Could not open file: $!";
        my @test_hands;
        while (my $line = <$fh>){
            chomp $line; ### HEHEHEHEHE CHOMP CHOMP CHOMP CHOMP
            my @cards = split(/[,]+/, $line);
            $line =~ s/^\s+|\s+$//g;
            next unless $line;
            print " $line\n";
            foreach my $card (@cards) {

                # Validate card length
                if ($card =~ /^ 10[DCHS]$/) {
                    print "\n*** ERROR - CARDS MUST BE 3 CHARACTERS LONG ***\n";
                    print "\n*** INVALID CARD LENGTH: $card ***\n\n\n";
                    exit(1);
                }elsif (length($card) != 3) {
                    print "\n*** ERROR - CARDS MUST BE 3 CHARACTERS LONG ***\n";
                    print "\n*** INVALID CARD LENGTH: $card ***\n\n\n";
                    exit(1);
                }
            }

            @cards = split(/[,\s]+/, $line);
            foreach my $card (@cards) {

                $card =~ s/^\s+|\s+$//g;

                # Check for lowercase suits
                if ($card =~ /[a-z]$/) {
                    print "\n*** ERROR - SUITS MUST BE UPPERCASE ***\n";
                    print "\n*** INVALID SUIT: $card ***\n\n\n";
                    exit(1);
                }

                # Check for duplicate cards
                if (exists $cards_in_deck{$card}) {
                    print "\n*** ERROR - DUPLICATE CARD FOUND IN DECK ***\n";
                    print "\n*** DUPLICATE: $card ***\n\n\n";
                    exit(1);
                }
                $cards_in_deck{$card} = 1;
            }

            $line =~ s/,\s*/ /g;
            push @test_hands, $line;
        }
        close $fh;

        my $test_deck = Deck->new(1);
        $test_deck->{delt_cards} = [@test_hands];
        print "\n";
        $test_deck->print_hands();
        $test_deck->rank_hands(\@test_hands);
        $test_deck->print_result();
    }else{
        # HEHEHE DIEEE
        die "Usage: perl poker.pl [filename]\n" 
    }
}

main(@ARGV);

