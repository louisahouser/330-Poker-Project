import java.util.*;

/**
 * The CreateDeck class manages the creation, shuffling, and dealing of a deck of cards,
 * as well as evaluating and ranking poker hands.
 */
public class CreateDeck {
    public Player[] result;         // Array to store player hands and their rankings
    public String c1, c2, c3, c4, c5, c6;  // Purpose unclear, possibly for individual cards
    public CreateCard[][] deckArray;  // 2D array representing the deck of cards
    public String[] deltCards;      // Array to store dealt card hands as strings
    public int rows, cols;          // Dimensions of the deckArray

    /**
     * Default constructor initializing the deck and related structures.
     */
    public CreateDeck() {
        result = new Player[6];
        deckArray = new CreateCard[4][13];
        deltCards = new String[6];
        rows = deckArray.length;
        cols = deckArray[0].length;
    }

    /**
     * Constructor for testing purposes, initializes a full deck of cards.
     * @param test Boolean flag to indicate test mode
     */
    public CreateDeck(boolean test) {
        this();
        String[] suits = {"D", "C", "H", "S"};
        String[] faces = {"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"};

        for (int i = 0; i < 4; i++) {
            for (int j = 0; j < 13; j++) {
                deckArray[i][j] = new CreateCard(suits[i], faces[j]);
            }
        }
    }

    /**
     * Retrieves a deck from a GameMode object.
     * @param mode The GameMode object containing the test array
     */
    public void retrieveDeck(GameMode mode) {
        System.arraycopy(mode.testArray, 0, deltCards, 0, 6);
    }

    /**
     * Prints the current state of the deck to the console.
     */
    public void retrieveCard() {
        System.out.println("*** Shuffled 52 card deck: ");
        for (int k = 0; k < rows; k++) {
            for (int m = 0; m < cols; m++) {
                System.out.print(deckArray[k][m].face + deckArray[k][m].suit + "  ");
            }
            System.out.println();
        }
    }

    /**
     * Shuffles the deck of cards.
     */
    public void shuffleDeck() {
        List<CreateCard> flatDeck = new ArrayList<>();
        for (CreateCard[] row : deckArray) {
            flatDeck.addAll(Arrays.asList(row));
        }
        Collections.shuffle(flatDeck);
        Iterator<CreateCard> it = flatDeck.iterator();
        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) {
                deckArray[i][j] = it.next();
            }
        }
    }

    /**
     * Prints the six dealt hands to the console.
     */
    public void printHands() {
        System.out.println("*** Here are the six hands...");
        for (String hand : deltCards) {
            System.out.println(hand);
        }
    }

    /**
     * Deals six hands of five cards each from the deck.
     */
    public void dealHands() {
        String[] hands = new String[6];
        int handIndex = 0;
        StringBuilder currentHand = new StringBuilder();
        int cardCount = 0;

        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) {
                if (cardCount >= 30) break;
                currentHand.append(deckArray[i][j].face).append(deckArray[i][j].suit).append(" ");
                cardCount++;
                if (cardCount % 5 == 0) {
                    hands[handIndex] = currentHand.toString().trim();
                    handIndex++;
                    currentHand = new StringBuilder();
                }
            }
            if (cardCount >= 30) break;
        }

        System.arraycopy(hands, 0, deltCards, 0, 6);
    }

    /**
     * Prints the remaining cards in the deck after dealing.
     */
    public void remainingDeck() {
        System.out.println("*** Here is what remains in the deck... ");
        int count = 0;
        for (int k = 0; k < rows; k++) {
            for (int m = 0; m < cols; m++) {
                if (count >= 30) {
                    System.out.print(deckArray[k][m].suit + deckArray[k][m].face + "  ");
                } else {
                    count++;
                }
            }
        }
        System.out.println();

        rankHands(deltCards);
    }

    /**
     * Ranks the dealt hands by creating Player objects and evaluating each hand.
     * @param arr Array of string representations of hands
     */
    public void rankHands(String[] arr) {
        for (int i = 0; i < 6; i++) {
            Player currentCard = new Player();
            currentCard.convertHand(arr[i]);
            currentCard.setFinalScores();
            result[i] = currentCard;
        }
        System.out.println();
    }

    /**
     * Swaps two Player objects.
     * @param a First Player object
     * @param b Second Player object
     */
    public void swap(Player a, Player b) {
        Player temp = new Player(a.hand, a.wordList, a.order);
        a.hand = b.hand;
        a.wordList = new ArrayList<>(b.wordList);
        a.order = b.order;
        b.hand = temp.hand;
        b.wordList = new ArrayList<>(temp.wordList);
        b.order = temp.order;
    }

    /**
     * Applies tiebreaker rules to rank hands of the same type.
     */
    public void tieBreakers() {
        for (int i = 0; i < 6; i++) {
            for (int j = i + 1; j < 6; j++) {
                if (result[i].order == result[j].order) {
                    // Apply different tiebreaker rules based on hand type
                    if (result[i].hand.equals("Straight Flush") || 
                        result[i].hand.equals("Flush") || 
                        result[i].hand.equals("Royal Straight Flush")) {
                        
                        // Tiebreaker for flush-based hands
                        char suitI = result[i].wordList.get(result[i].wordList.size() - 1).charAt(result[i].wordList.get(result[i].wordList.size() - 1).length() - 1);
                        char suitJ = result[j].wordList.get(result[j].wordList.size() - 1).charAt(result[j].wordList.get(result[j].wordList.size() - 1).length() - 1);
                        
                        if (rankSuits(suitI) < rankSuits(suitJ)) {
                            swap(result[i], result[j]);
                        } else if (rankSuits(suitI) == rankSuits(suitJ)) {
                            if (getHighCard(result[i]) < getHighCard(result[j])) {
                                swap(result[i], result[j]);
                            }
                        }
                    } else if (result[i].hand.equals("Straight")) {
                        // Tiebreaker for straights
                        if (getHighCard(result[i]) < getHighCard(result[j])) {
                            swap(result[i], result[j]);
                        }
                    } else if (result[i].hand.equals("Two Pair")) {
                        // Tiebreaker for two pairs
                        char suitI = getHighCardNI2P(result[i]);
                        char suitJ = getHighCardNI2P(result[j]);

                        if (rankSuits(suitI) < rankSuits(suitJ)) {
                            swap(result[i], result[j]);
                        } else if (rankSuits(suitI) == rankSuits(suitJ)) {
                            if (suitI < suitJ) {
                                swap(result[i], result[j]);
                            }
                        }
                    } else if (result[i].hand.equals("Pair")) {
                        // Tiebreaker for pairs
                        char suitI = getHighCardNIP(result[i]);
                        char suitJ = getHighCardNIP(result[j]);

                        if (rankSuits(suitI) < rankSuits(suitJ)) {
                            swap(result[i], result[j]);
                        } else if (rankSuits(suitI) == rankSuits(suitJ)) {
                            if (suitI < suitJ) {
                                swap(result[i], result[j]);
                            }
                        }
                    } else if (result[i].hand.equals("High Card")) {
                        // Tiebreaker for high card
                        char highCardI = getHighCard(result[i]);
                        char highCardJ = getHighCard(result[j]);

                        if (rankSuits(highCardI) < rankSuits(highCardJ)) {
                            swap(result[i], result[j]);
                        } else if (rankSuits(highCardI) == rankSuits(highCardJ)) {
                            if (highCardI < highCardJ) {
                                swap(result[i], result[j]);
                            }
                        }
                    } else if (result[i].hand.equals("Three of a Kind")) {
                        // Tiebreaker for three of a kind
                        int rankI = getTOAKRank(result[i]);
                        int rankJ = getTOAKRank(result[j]);

                        if (rankI < rankJ) {
                            swap(result[i], result[j]);
                        } else if (rankI == rankJ) {
                            List<Integer> kickersI = getKickers(result[i]);
                            List<Integer> kickersJ = getKickers(result[j]);

                            Collections.sort(kickersI, Collections.reverseOrder());
                            Collections.sort(kickersJ, Collections.reverseOrder());

                            for (int k = 0; k < kickersI.size(); k++) {
                                if (kickersI.get(k) < kickersJ.get(k)) {
                                    swap(result[i], result[j]);
                                    break;
                                } else if (kickersI.get(k) > kickersJ.get(k)) {
                                    break;
                                }
                            }

                            if (kickersI.equals(kickersJ)) {
                                char suitI = getHighCardSuit(result[i]);
                                char suitJ = getHighCardSuit(result[j]);

                                if (rankSuits(suitI) < rankSuits(suitJ)) {
                                    swap(result[i], result[j]);
                                }
                            }
                        }
                    } else if (result[i].hand.equals("Four of a Kind")) {
                        // Tiebreaker for four of a kind
                        int rankI = getFOAKRank(result[i]);
                        int rankJ = getFOAKRank(result[j]);

                        if (rankI < rankJ) {
                            swap(result[i], result[j]);
                        } else if (rankI == rankJ) {
                            int kickerI = getKicker(result[i]);
                            int kickerJ = getKicker(result[j]);
                            if (kickerI < kickerJ) {
                                swap(result[i], result[j]);
                            }
                        }
                    } else if (result[i].hand.equals("Full House")) {
                        // Tiebreaker for full house
                        int rankI = getTOAKRank(result[i]);
                        int rankJ = getTOAKRank(result[j]);

                        if (rankI < rankJ) {
                            swap(result[i], result[j]);
                        } else if (rankI == rankJ) {
                            List<Integer> kickersI = getKickers(result[i]);
                            List<Integer> kickersJ = getKickers(result[j]);

                            for (int k = 0; k < kickersI.size(); k++) {
                                if (kickersI.get(k) < kickersJ.get(k)) {
                                    swap(result[i], result[j]);
                                    break;
                                } else if (kickersI.get(k) > kickersJ.get(k)) {
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    /**
     * Assigns a numerical rank to each suit for comparison purposes.
     * @param suit The suit character
     * @return The numerical rank of the suit
     */
    private int rankSuits(char suit) {
        switch (suit) {
            case 'D': return 1;
            case 'C': return 2;
            case 'H': return 3;
            case 'S': return 4;
            default: return 0;
        }
    }

    /**
     * Gets the suit of the highest card in a player's hand that isn't part of a pair or set.
     * @param p The Player object
     * @return The suit of the highest card
     */
    public char getHighCardSuit(Player p) {
        int highCard = -1;
        char highSuit = ' ';
        Map<String, Integer> countMap = new HashMap<>();

        for (String card : p.wordList) {
            String face = card.substring(0, card.length() - 1);
            countMap.put(face, countMap.getOrDefault(face, 0) + 1);
        }

        for (String card : p.wordList) {
            String face = card.substring(0, card.length() - 1);
            char suit = card.charAt(card.length() - 1);

            if (countMap.get(face) == 1) {
                int faceValue = getFaceValue(face);
                if (faceValue > highCard) {
                    highCard = faceValue;
                    highSuit = suit;
                }
            }
        }

        return highSuit;
    }

/**
     * Gets the kickers (unpaired cards) in a player's hand.
     * @param p The Player object
     * @return A list of face values of the kickers
     */
    public List<Integer> getKickers(Player p) {
        Map<String, Integer> countMap = new HashMap<>();
        List<Integer> kickers = new ArrayList<>();

        // Count the occurrences of each face value
        for (String card : p.wordList) {
            String face = card.substring(0, card.length() - 1);
            countMap.put(face, countMap.getOrDefault(face, 0) + 1);
        }

        // Add face values of single cards (kickers) to the list
        for (String card : p.wordList) {
            String face = card.substring(0, card.length() - 1);
            if (countMap.get(face) == 1) {
                kickers.add(getFaceValue(face));
            }
        }

        return kickers;
    }

/**
     * Gets the suit of the highest card in a two pair hand.
     * @param p The Player object
     * @return The suit of the highest card in the two pair
     */
    public char getHighCardNI2P(Player p) {
        int highCard = -1;
        char highSuit = ' ';
        Map<String, Integer> countMap = new HashMap<>();

        for (String card : p.wordList) {
            String face = card.substring(0, card.length() - 1);
            countMap.put(face, countMap.getOrDefault(face, 0) + 1);
        }

        for (String card : p.wordList) {
            String face = card.substring(0, card.length() - 1);
            char suit = card.charAt(card.length() - 1);
            if (countMap.get(face) == 2) {
                int faceValue = getFaceValue(face);
                if (faceValue > highCard) {
                    highCard = faceValue;
                    highSuit = suit;
                }
            }
        }
        return highSuit;
    }

    /**
     * Gets the suit of the highest card in a pair hand.
     * @param p The Player object
     * @return The suit of the highest card not in the pair
     */
    public char getHighCardNIP(Player p) {
        int highCard = -1;
        char highSuit = ' ';
        Map<String, Integer> countMap = new HashMap<>();

        for (String card : p.wordList) {
            String face = card.substring(0, card.length() - 1);
            countMap.put(face, countMap.getOrDefault(face, 0) + 1);
        }

        for (String card : p.wordList) {
            String face = card.substring(0, card.length() - 1);
            char suit = card.charAt(card.length() - 1);
            if (countMap.get(face) == 1) {
                int faceValue = getFaceValue(face);
                if (faceValue > highCard) {
                    highCard = faceValue;
                    highSuit = suit;
                }
            }
        }

        return highSuit;
    }

    /**
     * Gets the suit of the highest card in a hand.
     * @param p The Player object
     * @return The suit of the highest card
     */
    public char getHighCard(Player p) {
        Map<String, Integer> countMap = new HashMap<>();
        for (String card : p.wordList) {
            String face = card.substring(0, card.length() - 1);
            countMap.put(face, countMap.getOrDefault(face, 0) + 1);
        }

        int highCard = -1;
        char highSuit = ' ';
        for (String card : p.wordList) {
            String face = card.substring(0, card.length() - 1);
            if (countMap.get(face) == 1) {
                int faceValue = getFaceValue(face);
                if (faceValue > highCard) {
                    highCard = faceValue;
                    highSuit = card.charAt(card.length() - 1);
                }
            }
        }
        return highSuit;
    }

    /**
     * Gets the rank of the three of a kind in a hand.
     * @param p The Player object
     * @return The face value of the three of a kind
     */
    public int getTOAKRank(Player p) {
        Map<String, Integer> countMap = new HashMap<>();
        for (String card : p.wordList) {
            String face = card.substring(0, card.length() - 1);
            countMap.put(face, countMap.getOrDefault(face, 0) + 1);
        }

        for (Map.Entry<String, Integer> entry : countMap.entrySet()) {
            if (entry.getValue() == 3) {
                return getFaceValue(entry.getKey());
            }
        }

        return -1;
    }

    /**
     * Gets the rank of the four of a kind in a hand.
     * @param p The Player object
     * @return The face value of the four of a kind
     */
    public int getFOAKRank(Player p) {
        Map<String, Integer> countMap = new HashMap<>();

        for (String card : p.wordList) {
            String face = card.substring(0, card.length() - 1);
            countMap.put(face, countMap.getOrDefault(face, 0) + 1);
        }

        for (Map.Entry<String, Integer> entry : countMap.entrySet()) {
            if (entry.getValue() == 4) {
                return getFaceValue(entry.getKey());
            }
        }

        return -1;
    }

    /**
     * Gets the ranks of the two pairs in a two pair hand.
     * @param p The Player object
     * @return A list of the face values of the two pairs, sorted in descending order
     */
    public List<Integer> getTwoPairRanks(Player p) {
        List<Integer> ranks = new ArrayList<>();
        Map<String, Integer> countMap = new HashMap<>();

        for (String card : p.wordList) {
            String face = card.substring(0, card.length() - 1);
            countMap.put(face, countMap.getOrDefault(face, 0) + 1);
        }

        for (Map.Entry<String, Integer> entry : countMap.entrySet()) {
            if (entry.getValue() == 2) {
                ranks.add(getFaceValue(entry.getKey()));
            }
        }

        Collections.sort(ranks, Collections.reverseOrder());
        return ranks;
    }

    /**
     * Gets the kicker (unpaired card) in a four of a kind hand.
     * @param p The Player object
     * @return The face value of the kicker
     */
    public int getKicker(Player p) {
        Map<String, Integer> countMap = new HashMap<>();
        for (String card : p.wordList) {
            String face = card.substring(0, card.length() - 1);
            countMap.put(face, countMap.getOrDefault(face, 0) + 1);
        }
        for (Map.Entry<String, Integer> entry : countMap.entrySet()) {
            if (entry.getValue() == 1) {
                return getFaceValue(entry.getKey());
            }
        }
        return -1;
    }

    /**
     * Converts a face value string to its corresponding integer value.
     * @param faceString The string representation of the card's face value
     * @return The integer value of the face
     */
    private int getFaceValue(String faceString) {
        switch (faceString) {
            case "J": return 11;
            case "Q": return 12;
            case "K": return 13;
            case "A": return 14;
            default: return Integer.parseInt(faceString);
        }
    }

    /**
     * Sorts the player results based on their hand order.
     */
    public void sortOrder() {
        Arrays.sort(result, Comparator.comparingInt(p -> p.order));
    }

    /**
     * Prints the final results of the hand rankings.
     */
    public void printResult() {
        sortOrder();
        tieBreakers();

        System.out.println("--- WINNING HAND ORDER ---");
        for (Player player : result) {
            for (String word : player.wordList) {
                System.out.print(word + " ");
            }
            System.out.println(" - " + player.hand);
        }
        System.out.println();
    }
}
