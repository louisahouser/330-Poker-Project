using System;
using System.IO;
using System.Linq;

// The GameMode class handles the setup and management of test scenarios for the poker hand analyzer
public class GameMode
{
    // 2D array to store individual cards for each hand
    public string[,] Entries { get; private set; }
    // Stores the name of the input file
    public string Filename { get; private set; }
    // Array to store complete hands as strings
    public string[] TestArray { get; private set; }

    // Default constructor initializing arrays
    public GameMode()
    {
        Entries = new string[6, 5];
        TestArray = new string[6];
    }

    // Constructor for test scenarios (currently identical to default constructor)
    public GameMode(bool test) : this()
    {
    }

    // Reads and processes the input file containing test hands
    public void ReadFile(string filename)
    {
        Filename = filename;
        try
        {
            // Read all lines from the file
            string[] lines = File.ReadAllLines(filename);
            for (int row = 0; row < Math.Min(6, lines.Length); row++)
            {
                string[] cards = lines[row].Split(',');
                for (int col = 0; col < Math.Min(5, cards.Length); col++)
                {
                    string card = cards[col].Trim();
                    ValidateCard(card);
                    Entries[row, col] = card;
                }
            }
        }
        catch (IOException e)
        {
            Console.Error.WriteLine($"Error reading file: {filename}");
            Environment.Exit(1);
        }

        // Print the contents of entries
        for (int i = 0; i < 6; i++)
        {
            for (int j = 0; j < 5; j++)
            {
                Console.Write(Entries[i, j]);
                Console.Write(j == 4 ? "\n" : ",");
            }
        }

        SetTestDeck();
    }

    // Validates individual card format
    private void ValidateCard(string card)
    {
        if (card.Length < 2 || card.Length > 3)
        {
            throw new ArgumentException($"Invalid card length: {card}");
        }
        if (!char.IsUpper(card[card.Length - 1]))
        {
            throw new ArgumentException($"Suit must be uppercase: {card}");
        }
        // Additional validation could be added here
    }

    // Prepares the test deck by formatting hands and storing them in TestArray
    public void SetTestDeck()
    {
        for (int i = 0; i < 6; i++)
        {
            string line = "";
            for (int j = 0; j < 5; j++)
            {
                string temp = Entries[i, j].Replace(" ", "");
                Entries[i, j] = temp;
                line += temp + " ";
            }
            TestArray[i] = line.Trim();
        }

        // Print the formatted hands
        Console.WriteLine("\n***Here are the six hands... ");
        foreach (string hand in TestArray)
        {
            Console.WriteLine(hand);
        }
    }

    // Initiates the hand ranking process using the CreateDeck class
    public void CallDeckClass(CreateDeck b)
    {
        b.RankHands(TestArray);
    }
}
