pragma solidity >=0.4.22 <0.6.0;

contract Hangman {
    uint MAX_GUESSES = 11;
    string[5] WORDS = ["test", "hangman", "ethereum", "cryptocurrency", "foo"];
    
    bytes internal currentWord;
    bytes solvedBytes;
    uint guessesLeft;
    
    uint internal nextIndex;
    
    uint amount;
    
    address creator;
    
    constructor() public {
        creator = msg.sender;
        
        nextIndex = 0;
        nextWord();
    }
    
    function getPuzzleState() public view returns(string memory state) {
        return string(abi.encodePacked(solvedBytes, "\n Number of guesses left: ", uint2str(guessesLeft)));
    }

    function guessLetter(string memory letter) public payable returns(string memory message) {
        bytes memory letterBytes = bytes(letter);
        
        // check if it is really only one letter
        if (letterBytes.length > 1) {
            // paypack the value to sender
            (msg.sender).transfer(msg.value);
            return "You are not allowed to guess a string with more than one character";
        }
        
        if (guessesLeft > 0) {
            // guess is allowed
            
            amount += msg.value;
            
            bool isLetterInWord = false;
            for (uint i = 0; i < currentWord.length; i++) {
                if (letterBytes[0] == currentWord[i]) {
                    // letter found!
                    isLetterInWord = true;
                    solvedBytes[i] = letterBytes[0];
                }
            }
            
            if (isLetterInWord) {
                // letter was in word
                // TODO payout reward if it was solved
                return "Letter was in the word";
            } else {
                // letter was not found
                guessesLeft--;
                // TODO: If this was the last guess: Payout and next word
                return "Letter was not in the word";
            }
            
        } else {
            // TODO: check if this case can happen!!!
            // no guesses left for this word, this case should not happen
            // paypack the value to sender
            (msg.sender).transfer(msg.value);
            nextWord();
            return "No guesses left for this word. Try the next one.";
        }
    }
    
    function guessWord(string memory word) public payable returns(bool) {
        bytes memory wordBytes = bytes(word);
        amount += msg.value;
        
        if (wordBytes.length != currentWord.length) {
            return false;
        }
        
        for (uint i = 0; i < wordBytes.length; i++) {
            if (wordBytes[i] != currentWord[i]) {
                return false;
            }
        }
        
        // word is correct
        // TODO payout reward
        nextWord();
        return true;
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
    
    function isWordSolved() internal returns(bool){
        for (uint i = 0; i < solvedBytes.length; i++) {
            if (solvedBytes[i] == "-") {
                return false;
            }
        }
        
        return true;
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
