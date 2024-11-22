///////////////// PLAYER CLASS
use std::collections::HashMap;  // For counting suits and card ranks
use crate::card::Card;         // For card-related utilities

// HandRank struct keeps track of what type of poker hand is present
#[derive(Debug, Default)]
pub struct HandRank {
    pub is_royal_flush: bool,      // A, K, Q, J, 10 of same suit
    pub is_straight_flush: bool,   // Five sequential cards of same suit
    pub is_four_kind: bool,        // Four cards of same rank
    pub is_full_house: bool,       // Three of a kind plus a pair
    pub is_flush: bool,            // Five cards of same suit
    pub is_straight: bool,         // Five sequential cards
    pub is_three_kind: bool,       // Three cards of same rank
    pub is_two_pair: bool,         // Two different pairs
    pub is_pair: bool,             // One pair
    pub is_high_card: bool,        // No other hand present
}

// Player struct represents a poker hand and its evaluation
#[derive(Debug)]
pub struct Player {
    pub hand: String,              // String description of final hand type
    pub word_list: Vec<String>,    // List of cards in hand
    pub order: u8,                 // Numeric rank of hand (1=best, 10=worst)
    pub suit_count: HashMap<char, u8>,  // Counts of each suit
    pub rank_count: HashMap<u8, u8>,    // Counts of each card rank
    pub hand_rank: HandRank,            // Types of poker hands present
}

impl Player {
    // Creates new Player instance from a hand string
    pub fn new(hand: String) -> Self {
        let mut player = Player {
            hand,
            word_list: Vec::new(),
            order: 0,
            suit_count: HashMap::new(),
            rank_count: HashMap::new(),
            hand_rank: HandRank::default(),
        };

        player.convert_hand();  // Process the hand
        player
    }

    // Converts hand string into processed data structures
    pub fn convert_hand(&mut self) {
        self.hand_rank = HandRank::default();

        // Split hand into individual cards
        let cards: Vec<&str> = self.hand.split_whitespace().collect();
        self.word_list = cards.iter().map(|&s| s.to_string()).collect();

        // Count suits and ranks
        for word in &self.word_list {
            let face_string = &word[..word.len()-1];
            let suit_char = word.chars().last().unwrap();

            // Increment suit count
            *self.suit_count.entry(suit_char).or_insert(0) += 1;
            // Increment rank count using numeric values
            let face_val = Card::face_to_value(face_string);
            *self.rank_count.entry(face_val).or_insert(0) += 1;
        }

        self.evaluate_hand();
    }

    // Evaluates the hand to determine its type
    pub fn evaluate_hand(&mut self) {
        // Check for combination hands first
        if self.is_flush() && self.is_straight() && self.is_royal() {
            self.hand_rank.is_royal_flush = true;
        }else if self.is_flush() && self.is_straight() {
            self.hand_rank.is_straight_flush = true;
        }else if self.is_flush() {
            self.hand_rank.is_flush = true;
        }else if self.is_straight() {
            self.hand_rank.is_straight = true;
        }

        self.find_pairs();  // Check for pairs, three/four of a kind
    }

    //////////  HELPER FUNCS

    // Checks if all cards are the same suit
    pub fn is_flush(&self) -> bool {
        self.suit_count.values().any(|&count| count == 5)
    }

    // Checks if cards form a sequential straight
    pub fn is_straight(&self) -> bool {
        let mut rankings: Vec<_> = self.rank_count.keys().collect();
        rankings.sort_unstable();

        // Special case: Ace-low straight (A,2,3,4,5)
        if rankings == vec![&2, &3, &4, &5, &14] {
            return true;
        }

        // Normal straight: each card is one more than previous
        for i in 1..rankings.len() {
            if rankings[i] != &(rankings[i-1] + 1) {
                return false;
            }
        }
        true
    }

    // Checks if hand is royal (10,J,Q,K,A)
    pub fn is_royal(&self) -> bool {
        let royal_values = vec![10, 11, 12, 13, 14];
        royal_values.iter().all(|&val| self.rank_count.contains_key(&val))
    }

    // Identifies pairs, three of a kind, four of a kind
    pub fn find_pairs(&mut self) {
        let mut pair_count = 0;

        // Count sets of same rank
        for &rank in self.rank_count.values() {
            match rank {
                4 => self.hand_rank.is_four_kind = true,
                3 => self.hand_rank.is_three_kind = true,
                2 => pair_count += 1,
                _ => {}
            }
        }

        // Set appropriate hand types
        match pair_count {
            2 => self.hand_rank.is_two_pair = true,
            1 => self.hand_rank.is_pair = true,
            _ => {}
        }

        // Check for full house
        if self.hand_rank.is_three_kind && self.hand_rank.is_pair {
            self.hand_rank.is_full_house = true;
        }

        // If no pairs/sets, it's a high card hand
        if !self.hand_rank.is_pair &&
           !self.hand_rank.is_three_kind &&
           !self.hand_rank.is_four_kind {
            self.hand_rank.is_high_card = true;
        }
    }

    // Sets final hand type and numeric rank
    pub fn set_final_scores(&mut self) {
        if self.hand_rank.is_royal_flush {
            self.hand = String::from("Royal Straight Flush");
            self.order = 1;
        }else if self.hand_rank.is_straight_flush {
            self.hand = String::from("Straight Flush");
            self.order = 2;
        }else if self.hand_rank.is_four_kind {
            self.hand = String::from("Four of a Kind");
            self.order = 3;
        }else if self.hand_rank.is_full_house {
            self.hand = String::from("Full House");
            self.order = 4;
        }else if self.hand_rank.is_flush {
            self.hand = String::from("Flush");
            self.order = 5;
        }else if self.hand_rank.is_straight {
            self.hand = String::from("Straight");
            self.order = 6;
        }else if self.hand_rank.is_three_kind {
            self.hand = String::from("Three of a Kind");
            self.order = 7;
        }else if self.hand_rank.is_two_pair {
            self.hand = String::from("Two Pair");
            self.order = 8;
        }else if self.hand_rank.is_pair {
            self.hand = String::from("Pair");
            self.order = 9;
        }else {
            self.hand = String::from("High Card");
            self.order = 10;
        }
    }

    //////////////// tiebreaker helper funcs

    // Gets highest single card in hand
    pub fn get_high_card(&self) -> u8 {
        let mut high_card = 0;
        for (&face_val, &count) in &self.rank_count {
            if count == 1 && face_val > high_card {
                high_card = face_val;
            }
        }
        high_card
    }

    // Gets first single card (kicker) in hand
    pub fn get_kicker(&self) -> u8 {
        for (&face_val, &count) in &self.rank_count {
            if count == 1 {
                return face_val;
            }
        }
        0
    }

    // Gets rank of three of a kind
    pub fn get_toak_rank(&self) -> u8 {
        for (&face_val, &count) in &self.rank_count {
            if count == 3 {
                return face_val;
            }
        }
        0
    }

    // Gets rank of four of a kind
    pub fn get_foak_rank(&self) -> u8 {
        for (&face_val, &count) in &self.rank_count {
            if count == 4 {
                return face_val;
            }
        }
        0
    }

    // Gets ranks of pairs in descending order
    pub fn get_to_pair_ranks(&self) -> Vec<u8> {
        let mut pairs: Vec<u8> = self.rank_count
            .iter()
            .filter(|&(_, &count)| count == 2)
            .map(|(&face_val, _)| face_val)
            .collect();
        pairs.sort_unstable_by(|a, b| b.cmp(a));
        pairs
    }

    // Gets suit of kicker card
    pub fn get_kicker_suit(&self) -> char {
        for card in &self.word_list {
            let face = &card[..card.len()-1];
            if *self.rank_count.get(&Card::face_to_value(face)).unwrap_or(&0) == 1 {
                return card.chars().last().unwrap();
            }
        }
        ' '
    }

    // Gets suit of highest single card
    pub fn get_high_card_suit(&self) -> char {
        let mut high_card = 0;
        let mut high_suit = ' ';

        for card in &self.word_list {
            let face = &card[..card.len()-1];
            let face_val = Card::face_to_value(face);
            if *self.rank_count.get(&face_val).unwrap_or(&0) == 1 && face_val > high_card {
                high_card = face_val;
                high_suit = card.chars().last().unwrap();
            }
        }
        high_suit
    }
}

