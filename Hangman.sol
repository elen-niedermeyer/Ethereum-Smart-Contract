pragma solidity >=0.4.22 <0.6.0;

contract Hangman {
    uint256 MAX_GUESSES = 11;
    
    string[] proposedWords;
    uint256 nextIndex;
    
    bytes currentWord;
    bytes solvedBytes;
    
    uint256 guessesLeft;
    
    
    
    constructor() public {
        proposedWords.length = 5;
        
        nextIndex = 0;
        guessesLeft = MAX_GUESSES;
    }
    
    // Allows to enter a new word into the list of words.
    // The proposed word must match [A-Z]+
    function proposeWord(string memory word) public {
        if (WordRegex.matches(word)) {
            proposedWords[nextIndex] = word;
            nextIndex += 1; // TODO: limit #words?
        }
    }
    
    function guessLetter(byte letter) public {
        if (guessesLeft > 0) {
            // guess is allowed
            bool isLetterInWord = false;
            for (uint8 i = 0; i < currentWord.length; i++) {
                if (letter == currentWord[i]) {
                    // letter found!
                    isLetterInWord = true;
                    solvedBytes[i] = letter;
                }
            }
            
            if (!isLetterInWord) {
                // letter was not found
                guessesLeft--;
            }
            
        } else {
            //TODO: return error?
            nextWord();
        }
    }
    
    function nextWord() internal {
        // next word
        currentWord = bytes(proposedWords[nextIndex]);
        
        // update index
        if (nextIndex == proposedWords.length-1) {
            nextIndex = 0;
        } else {
            nextIndex++;
        }
            
        // reset solved bytes
        solvedBytes = bytes(currentWord);
        for (uint8 i = 0; i < solvedBytes.length; i++) {
            solvedBytes[i] = "-";
        }
         
        // reset number of guesses   
        guessesLeft = MAX_GUESSES;
    }
    
}
