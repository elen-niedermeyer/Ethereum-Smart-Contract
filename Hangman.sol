pragma solidity >=0.5.0;

contract Hangman {
    uint MAX_GUESSES = 11;
    string[5] WORDS = ["test", "hangman", "ethereum", "cryptocurrency", "foo"];
    
    bytes internal currentWord;
    bytes internal solvedBytes;
    uint internal guessesLeft;
    
    uint internal nextIndex;
    
    address payable private creator;
    
    constructor() public {
        creator = msg.sender;
        
        nextIndex = 0;
        nextWord();
    }
    
    function getPuzzleState() public view returns(string memory state) {
        return string(abi.encodePacked(solvedBytes, "\n Number of guesses left: ", uint2str(guessesLeft)));
    }

    function guessLetter(string memory letter) public payable {
        bytes memory letterBytes = bytes(letter);
        require(letterBytes.length == 1, "You have to input only ONE lowercase letter");
        
        bool isLetterInWord = false;
        for (uint i = 0; i < currentWord.length; i++) {
            if (letterBytes[0] == currentWord[i]) {
                // letter found!
                isLetterInWord = true;
                solvedBytes[i] = letterBytes[0];
            }
        }
            
        if (isWordSolved()) {
            puzzleSolved();
        }

        if (!isLetterInWord) {
            // letter was not found
            guessesLeft--;
        }
        
        if (guessesLeft == 0) {
            puzzleNotSolved();
        }
    }
    
    function guessWord(string memory word) public payable returns(bool) {
        bytes memory wordBytes = bytes(word);
       
        if (wordBytes.length != currentWord.length) {
            return false;
        }
        
        for (uint i = 0; i < wordBytes.length; i++) {
            if (wordBytes[i] != currentWord[i]) {
                return false;
            }
        }
        
        // word is correct
        puzzleSolved();
        return true;
    }
    
    function isWordSolved() internal view returns(bool){
        for (uint i = 0; i < solvedBytes.length; i++) {
            if (solvedBytes[i] == "-") {
                return false;
            }
        }
        
        return true;
    }

    function puzzleSolved() internal {
        msg.sender.transfer(msg.value);
        nextWord();
    }
    
    function puzzleNotSolved() internal {
        creator.transfer(address(this).balance);
        nextWord();
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
