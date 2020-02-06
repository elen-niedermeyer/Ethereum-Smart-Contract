pragma solidity >=0.5.0;

import "./word_regex.sol";

contract Hangman {
    uint LETTER_GUESS_COST = 0.0003 ether; // ~ 5ct on 1st February 2020
    uint WORD_GUESS_COST = 0.0005 ether; // ~ 8ct on 1st February 2020
    
    uint MAX_GUESSES = 11;
    uint MAX_WORDS = 10;
    string[] WORDS = ["ethereum", "cryptocurrency"];
    uint word_ptr_start;
    uint word_ptr_end;
    
    bytes internal currentWord;
    bytes internal solvedBytes;
    // hold the letters guessed for the current word
    bytes internal guessedLetters;
    uint internal guessesLeft;
        
    address payable private creator;
    
    constructor() public {
        creator = msg.sender;

        // initialize ring buffer
        if (WORDS.length > 0)
        	word_ptr_end = WORDS.length - 1;
        
        nextWord();
    }
    
    function getPuzzleState() public view returns(string memory state) {
        return string(abi.encodePacked(
            solvedBytes,
            "\nNumber of guesses left: ",
            uint2str(guessesLeft),
            "\nGuessed letters: ",
            guessedLetters
        ));
    }

    // Allows to enter a new word into the list of words.
    // The proposed word must match [a-z]+
    function proposeWord(string memory word) public {
        require(bytes(word).length < 40, "Max word length is 40 letters.");
        require(!isBufferFull(), "Max number of words (10) reached. Solve a puzzle first before proposing new words.");

        if (WordRegex.matches(word)) {
        	WORDS[nextInsertPos()] = word;
        }
    }

    function guessLetter(string memory letter) public payable {
        // check payed fee
        require(msg.value >= LETTER_GUESS_COST, string(abi.encodePacked("Please pay at least ", uint2str(LETTER_GUESS_COST), " wei")));

        bytes memory letterBytes = bytes(letter);
        // validate input
        require(letterBytes.length == 1, "You have to input only ONE lowercase letter");
        
        // add to already guessed letters
        bool alreadyGuessed = false;
        for (uint i = 0; i < guessedLetters.length; i++) {
            if (guessedLetters[i] == letterBytes[0]) // should be one byte
                alreadyGuessed = true;
        }
        if (!alreadyGuessed)
            guessedLetters.push(letterBytes[0]);
        
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
        // check payed fee
        require(msg.value >= WORD_GUESS_COST, string(abi.encodePacked("Please pay at least ", uint2str(WORD_GUESS_COST), " wei")));
        
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
        msg.sender.transfer(address(this).balance);
        nextWord();
    }
    
    function puzzleNotSolved() internal {
        creator.transfer(address(this).balance);
        nextWord();
    }
    
    function nextWord() internal {
        // next word
        currentWord = bytes(WORDS[movePointer()]);
                    
        // reset solved bytes
        solvedBytes = bytes(currentWord);
        for (uint i = 0; i < solvedBytes.length; i++) {
            solvedBytes[i] = "-";
        }
         
        // reset number of guesses   
        guessesLeft = MAX_GUESSES;
        // reset guessed letters
        guessedLetters = new bytes(0);
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

    // check if the words ring buffer is full
    function isBufferFull() internal view returns (bool) {
    	return word_ptr_end + 1 == word_ptr_start;
    }

    // advance ring buffer insert pointer and return it
    function nextInsertPos() internal returns (uint) {
    	uint a = word_ptr_end + 1;
    	if (a > MAX_WORDS - 1)
    		word_ptr_end = 0;
    	else
    		word_ptr_end = a;
    	return word_ptr_end;
    }
    
    // advance ring buffer current pointer and return ist
    function movePointer() internal returns (uint) {
    	uint a = word_ptr_start + 1;
    	if (a > MAX_WORDS - 1)
    		word_ptr_start = 0;
		else
			word_ptr_start = a;
    	return word_ptr_start;
    }

}
