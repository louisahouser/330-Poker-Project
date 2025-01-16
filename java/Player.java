import java.util.*;

/**
 * Represents a player in the poker game, managing their hand of cards.
 */
public class Player {
    // Public fields representing the player's hand and its evaluation
    public String cards;
    public String hand;
    public int order;
    public List<String> wordList;
    public Map<String, Integer> wordCount;

    // Private fields for internal hand analysis
    private List<String> keepCount;
    private Map<Character, Integer> suitCount;
    private Map<Integer, Integer> rankCount;

    /**
     * Default constructor initializing all collections.
     */
    public Player() {
        wordList = new ArrayList<>();
        wordCount = new HashMap<>();
        keepCount = new ArrayList<>();
        suitCount = new HashMap<>();
        rankCount = new HashMap<>();
    }

    /**
     * Parameterized constructor for creating a player with a specific hand and order.
     */
    public Player(String hand2, List<String> wordList2, int order2) {
        this.hand = hand2;
        this.wordList = new ArrayList<>(wordList2);
        this.order = order2;
        this.wordCount = new HashMap<>();
        this.keepCount = new ArrayList<>();
        this.suitCount = new HashMap<>();
        this.rankCount = new HashMap<>();
    }

    /**
     * Sets the final hand type and order based on global flags.
     */
    public void setFinalScores() {
        if (Globals.RSF) {
            hand = "Royal Straight Flush";
            order = 5;
            Globals.RSF = false;
        } else if (Globals.SF) {
            hand = "Straight Flush";
            order = 6;
            Globals.SF = false;
        } else if (Globals.FOAK) {
            hand = "Four of a Kind";
            order = 7;
            Globals.FOAK = false;
        } else if (Globals.FH) {
            hand = "Full House";
            order = 8;
            Globals.FH = false;
        } else if (Globals.FLUSH) {
            hand = "Flush";
            order = 9;
            Globals.FLUSH = false;
        } else if (Globals.STRAIGHT) {
            hand = "Straight";
            order = 10;
            Globals.STRAIGHT = false;
        } else if (Globals.TOAK) {
            hand = "Three of a Kind";
            order = 11;
            Globals.TOAK = false;
        } else if (Globals.TP) {
            hand = "Two Pair";
            order = 12;
            Globals.TP = false;
        } else if (Globals.PAIR) {
            hand = "Pair";
            order = 13;
            Globals.PAIR = false;
        } else {
            hand = "High Card";
            order = 14;
        }
    }

    /**
     * Converts the string representation of a hand into internal data structures.
     */
    public void convertHand(String cards) {
        // Reset all globals to false to prevent overlap
        Globals.RSF = false;
        Globals.SF = false;
        Globals.FOAK = false;
        Globals.FH = false;
        Globals.FLUSH = false;
        Globals.STRAIGHT = false;
        Globals.TOAK = false;
        Globals.TP = false;
        Globals.PAIR = false;
        Globals.HC = false;

        String[] words = cards.split("\\s+");
        for (String word : words) {
            wordList.add(word);
            String faceString = word.substring(0, word.length() - 1);
            char suitChar = word.charAt(word.length() - 1);

            suitCount.put(suitChar, suitCount.getOrDefault(suitChar, 0) + 1);

            int faceVal = getFaceValue(faceString);
            rankCount.put(faceVal, rankCount.getOrDefault(faceVal, 0) + 1);
        }

        evaluateHand();
    }

    /**
     * Converts a face value string to its corresponding integer value.
     */
    private int getFaceValue(String faceString) {
        switch (faceString) {
            case "10": return 10;
            case "J": return 11;
            case "Q": return 12;
            case "K": return 13;
            case "A": return 14;
            default:
                try {
                    return Integer.parseInt(faceString);
                } catch (NumberFormatException e) {
                    System.err.println("Invalid face value: " + faceString);
                    return -1;
                }
        }
    }

    /**
     * Evaluates the hand to determine its type (flush, straight, etc.).
     */
    public void evaluateHand() {
        boolean flush = isFlush();
        boolean straight = isStraight();

        if (flush && straight && isRoyal()) {
            Globals.RSF = true;
        } else if (flush && straight) {
            Globals.SF = true;
        } else if (flush) {
            Globals.FLUSH = true;
        } else if (straight) {
            Globals.STRAIGHT = true;
        }

        findPairs();
    }

    /**
     * Checks if the hand is a flush (all cards of the same suit).
     */
    private boolean isFlush() {
        for (int count : suitCount.values()) {
            if (count == 5) {
                return true;
            }
        }
        return false;
    }

    /**
     * Checks if the hand is a straight (five cards in sequence).
     */
    private boolean isStraight() {
        List<Integer> rankings = new ArrayList<>(rankCount.keySet());
        if (rankings.size() < 5) {
            return false;
        }

        Collections.sort(rankings);

        for (int i = 1; i < rankings.size(); i++) {
            if (rankings.get(i) != rankings.get(i-1) + 1) {
                // Check for low ace straight
                if (rankings.equals(Arrays.asList(2, 3, 4, 5, 14))) {
                    return true;
                }
                return false;
            }
        }

        return true;
    }

    /**
     * Checks if the hand is a royal flush.
     */
    private boolean isRoyal() {
        return rankCount.containsKey(10) && rankCount.containsKey(11) &&
               rankCount.containsKey(12) && rankCount.containsKey(13) &&
               rankCount.containsKey(14);
    }

    /**
     * Identifies pairs, three of a kind, and four of a kind in the hand.
     */
    private void findPairs() {
        int pairCount = 0;
        boolean hasThreeOfAKind = false;
        boolean hasFourOfAKind = false;

        for (int count : rankCount.values()) {
            if (count == 4) {
                hasFourOfAKind = true;
            } else if (count == 3) {
                hasThreeOfAKind = true;
            } else if (count == 2) {
                pairCount++;
            }
        }

        if (hasFourOfAKind) {
            Globals.FOAK = true;
        } else if (hasThreeOfAKind && pairCount == 1) {
            Globals.FH = true;
        } else if (hasThreeOfAKind) {
            Globals.TOAK = true;
        } else if (pairCount == 2) {
            Globals.TP = true;
        } else if (pairCount == 1) {
            Globals.PAIR = true;
        } else if (!Globals.FLUSH && !Globals.STRAIGHT) {
            Globals.HC = true;
        }
    }
}
