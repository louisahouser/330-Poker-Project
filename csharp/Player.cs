using System;
using System.Collections.Generic;
using System.Linq;

// The Player class represents a player in a poker game, managing their hand and evaluating it
public class Player
{
    // Properties to store the player's cards, hand type, order, and word-related information
    public string Cards { get; set; }
    public string Hand { get; set; }
    public int Order { get; set; }
    public List<string> WordList { get; set; }
    public Dictionary<string, int> WordCount { get; set; }

    // Private fields for internal calculations and tracking
    private List<string> keepCount;
    private Dictionary<char, int> suitCount;
    private Dictionary<int, int> rankCount;

    // Default constructor initializing all collections
    public Player()
    {
        WordList = new List<string>();
        WordCount = new Dictionary<string, int>();
        keepCount = new List<string>();
        suitCount = new Dictionary<char, int>();
        rankCount = new Dictionary<int, int>();
    }

    // Parameterized constructor for initializing a player with specific hand, word list, and order
    public Player(string hand2, List<string> wordList2, int order2)
    {
        Hand = hand2;
        WordList = new List<string>(wordList2);
        Order = order2;
        WordCount = new Dictionary<string, int>();
        keepCount = new List<string>();
        suitCount = new Dictionary<char, int>();
        rankCount = new Dictionary<int, int>();
    }

    // Sets the final hand type and order based on global flags
    public void SetFinalScores()
    {
        if (Globals.RSF)
        {
            Hand = "Royal Straight Flush";
            Order = 5;
            Globals.RSF = false;
        }
        else if (Globals.SF)
        {
            Hand = "Straight Flush";
            Order = 6;
            Globals.SF = false;
        }
        else if (Globals.FOAK)
        {
            Hand = "Four of a Kind";
            Order = 7;
            Globals.FOAK = false;
        }
        else if (Globals.FH)
        {
            Hand = "Full House";
            Order = 8;
            Globals.FH = false;
        }
        else if (Globals.FLUSH)
        {
            Hand = "Flush";
            Order = 9;
            Globals.FLUSH = false;
        }
        else if (Globals.STRAIGHT)
        {
            Hand = "Straight";
            Order = 10;
            Globals.STRAIGHT = false;
        }
        else if (Globals.TOAK)
        {
            Hand = "Three of a Kind";
            Order = 11;
            Globals.TOAK = false;
        }
        else if (Globals.TP)
        {
            Hand = "Two Pair";
            Order = 12;
            Globals.TP = false;
        }
        else if (Globals.PAIR)
        {
            Hand = "Pair";
            Order = 13;
            Globals.PAIR = false;
        }
        else
        {
            Hand = "High Card";
            Order = 14;
        }
    }

    // Converts a string representation of cards into internal data structures and evaluates the hand
    public void ConvertHand(string cards)
    {
        // Reset all globals to false to prevent overlap
        Globals.RSF = Globals.SF = Globals.FOAK = Globals.FH = Globals.FLUSH = 
        Globals.STRAIGHT = Globals.TOAK = Globals.TP = Globals.PAIR = Globals.HC = false;

        string[] words = cards.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
        foreach (string word in words)
        {
            WordList.Add(word);
            string faceString = word.Substring(0, word.Length - 1);
            char suitChar = word[word.Length - 1];

            // Count occurrences of each suit
            suitCount[suitChar] = suitCount.ContainsKey(suitChar) ? suitCount[suitChar] + 1 : 1;

            // Convert face value to numeric and count occurrences
            int faceVal = GetFaceValue(faceString);
            rankCount[faceVal] = rankCount.ContainsKey(faceVal) ? rankCount[faceVal] + 1 : 1;
        }

        EvaluateHand();
    }

    // Converts a face value string to its corresponding numeric value
    private int GetFaceValue(string faceString)
    {
        switch (faceString)
        {
            case "10": return 10;
            case "J": return 11;
            case "Q": return 12;
            case "K": return 13;
            case "A": return 14;
            default:
                if (int.TryParse(faceString, out int result))
                    return result;
                else
                {
                    Console.Error.WriteLine($"Invalid face value: {faceString}");
                    return -1;
                }
        }
    }

    // Evaluates the player's hand and sets appropriate global flags
    public void EvaluateHand()
    {
        bool flush = IsFlush();
        bool straight = IsStraight();

        if (flush && straight && IsRoyal())
        {
            Globals.RSF = true;
        }
        else if (flush && straight)
        {
            Globals.SF = true;
        }
        else if (flush)
        {
            Globals.FLUSH = true;
        }
        else if (straight)
        {
            Globals.STRAIGHT = true;
        }

        FindPairs();
    }

    // Checks if the hand is a flush (all cards of the same suit)
    private bool IsFlush()
    {
        return suitCount.Values.Any(count => count == 5);
    }

    // Checks if the hand is a straight (five cards in sequence)
    private bool IsStraight()
    {
        List<int> rankings = new List<int>(rankCount.Keys);
        if (rankings.Count < 5)
        {
            return false;
        }

        rankings.Sort();

        for (int i = 1; i < rankings.Count; i++)
        {
            if (rankings[i] != rankings[i-1] + 1)
            {
                // Check for low ace straight (A, 2, 3, 4, 5)
                if (rankings.SequenceEqual(new List<int> { 2, 3, 4, 5, 14 }))
                {
                    return true;
                }
                return false;
            }
        }

        return true;
    }

    // Checks if the hand is a royal flush (10, J, Q, K, A of the same suit)
    private bool IsRoyal()
    {
        return rankCount.ContainsKey(10) && rankCount.ContainsKey(11) &&
               rankCount.ContainsKey(12) && rankCount.ContainsKey(13) &&
               rankCount.ContainsKey(14);
    }

    // Identifies pairs, three of a kind, and four of a kind in the hand
    private void FindPairs()
    {
        int pairCount = 0;
        bool hasThreeOfAKind = false;
        bool hasFourOfAKind = false;

        foreach (int count in rankCount.Values)
        {
            if (count == 4)
            {
                hasFourOfAKind = true;
            }
            else if (count == 3)
            {
                hasThreeOfAKind = true;
            }
            else if (count == 2)
            {
                pairCount++;
            }
        }

        if (hasFourOfAKind)
        {
            Globals.FOAK = true;
        }
        else if (hasThreeOfAKind && pairCount == 1)
        {
            Globals.FH = true;
        }
        else if (hasThreeOfAKind)
        {
            Globals.TOAK = true;
        }
        else if (pairCount == 2)
        {
            Globals.TP = true;
        }
        else if (pairCount == 1)
        {
            Globals.PAIR = true;
        }
        else if (!Globals.FLUSH && !Globals.STRAIGHT)
        {
            Globals.HC = true;
        }
    }
}
