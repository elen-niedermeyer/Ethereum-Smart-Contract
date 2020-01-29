pragma solidity >=0.4.22 <0.6.0;

contract Hangman {
    uint MAX_GUESSES = 11;
    string[] WORDS = ["test", "hangman", "ethereum", "cryptocurrency", "foo"];
    uint wordInsertPtr;
    
    bytes solvedBytes;
    uint guessesLeft;
    
    uint internal nextIndex;
    
    bytes internal currentWord;
    
    constructor() public {
        nextIndex = 0;
        nextWord();
    }

    // Allows to enter a new word into the list of words.
    // The proposed word must match [a-z]+
    function proposeWord(string memory word) public {
        if (WordRegex.matches(word)) {
            WORDS[wordInsertPtr] = word;
            wordInsertPtr += 1; // TODO: limit #words?
        }
    }

    function guessLetter(string memory letter) public returns(string memory message) {
        bytes memory letterBytes = bytes(letter);
        if (letterBytes.length > 1) {
            return "You are not allowed to guess a string with more than one character";
        }
        
        if (guessesLeft > 0) {
            // guess is allowed
            bool isLetterInWord = false;
            for (uint i = 0; i < currentWord.length; i++) {
                if (letterBytes[0] == currentWord[i]) {
                    // letter found!
                    isLetterInWord = true;
                    solvedBytes[i] = letterBytes[0];
                }
            }
            
            if (isLetterInWord) {
                return "Letter was in the word";
            } else {
                // letter was not found
                guessesLeft--;
                return "Letter was not in the word";
            }
            
        } else {
            // no guesses left for this word
            nextWord();
            return "No guesses left for this word. Try the next one.";
        }
    }
    
    function guessWord(string memory word) public returns(bool) {
        bytes memory wordBytes = bytes(word);
        
        if (wordBytes.length != currentWord.length) {
            return false;
        }
        
        for (uint i = 0; i < wordBytes.length; i++) {
            if (wordBytes[i] != currentWord[i]) {
                return false;
            }
        }
        
        nextWord();
        return true;
    }
    
    function getPuzzleState() public view returns(string memory state) {
        return string(abi.encodePacked(solvedBytes, "\n Number of guesses left: ", uint2str(guessesLeft)));
    }
    
    function nextWord() internal {
        // next word
        currentWord = bytes(WORDS[nextIndex]);
        
        // update index
        if (nextIndex == WORDS.length-1) {
            nextIndex = 0;
        } else {
            nextIndex++;
        }
            
        // reset solved bytes
        solvedBytes = bytes(currentWord);
        for (uint i = 0; i < solvedBytes.length; i++) {
            solvedBytes[i] = "-";
        }
         
        // reset number of guesses   
        guessesLeft = MAX_GUESSES;
    }

    // copied from the internet
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}
