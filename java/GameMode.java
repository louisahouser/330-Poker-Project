import java.io.*;
import java.util.*;

/**
 * The GameMode class handles the setup and processing of test data for the poker game.
 * It reads hands from a file, validates the cards, and prepares the data for analysis.
 */
public class GameMode {
    /** 2D array to store individual cards of each hand */
    public String[][] entries;
    
    /** Name of the file containing test data */
    public String filename;
    
    /** Array to store complete hands as strings */
    public String[] testArray;

    /**
     * Default constructor initializing arrays for storing hand data.
     */
    public GameMode() {
        entries = new String[6][5];  // 6 hands, 5 cards each
        testArray = new String[6];   // 6 complete hands
    }

    /**
     * Constructor for test mode (currently identical to default constructor).
     * @param test Boolean flag for test mode (unused)
     */
    public GameMode(boolean test) {
        this();
    }

    /**
     * Reads and processes the test data file.
     * @param filename Name of the file to read
     */
    public void readFile(String filename) {
        this.filename = filename;
        try (BufferedReader br = new BufferedReader(new FileReader(filename))) {
            String line;
            int row = 0;
            while ((line = br.readLine()) != null && row < 6) {
                String[] cards = line.split(",");
                for (int col = 0; col < 5 && col < cards.length; col++) {
                    String card = cards[col].trim();
                    validateCard(card);
                    entries[row][col] = card;
                }
                row++;
            }
        } catch (IOException e) {
            System.err.println("Error reading file: " + filename);
            System.exit(1);
        }

        // Print the contents of entries
        for (int i = 0; i < 6; i++) {
            for (int j = 0; j < 5; j++) {
                System.out.print(entries[i][j]);
                System.out.print(j == 4 ? "\n" : ",");
            }
        }

        setTestDeck();
    }

    /**
     * Validates individual card strings.
     * @param card The card string to validate
     * @throws IllegalArgumentException if the card is invalid
     */
    private void validateCard(String card) {
        if (card.length() < 2 || card.length() > 3) {
            throw new IllegalArgumentException("Invalid card length: " + card);
        }
        if (!Character.isUpperCase(card.charAt(card.length() - 1))) {
            throw new IllegalArgumentException("Suit must be uppercase: " + card);
        }
        // Additional validation could be added here
    }

    /**
     * Prepares the test deck by formatting the entries into complete hand strings.
     */
    public void setTestDeck() {
        for (int i = 0; i < 6; i++) {
            StringBuilder line = new StringBuilder();
            for (int j = 0; j < 5; j++) {
                String temp = entries[i][j].replaceAll("\\s+", "");
                entries[i][j] = temp;
                line.append(temp).append(" ");
            }
            testArray[i] = line.toString().trim();
        }

        System.out.println("\n***Here are the six hands... ");
        for (String hand : testArray) {
            System.out.println(hand);
        }
    }

    /**
     * Calls the rankHands method of the CreateDeck class with the prepared test hands.
     * @param b The CreateDeck object to use for ranking hands
     */
    public void callDeckClass(CreateDeck b) {
        b.rankHands(testArray);
    }
}
