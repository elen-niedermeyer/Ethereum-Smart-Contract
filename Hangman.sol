pragma solidity >=0.5.0;

import "./word_regex.sol";

contract Hangman {
    uint LETTER_GUESS_COST = 0.0003 ether; // ~ 5ct on 1st February 2020
    uint WORD_GUESS_COST = 0.0005 ether; // ~ 8ct on 1st February 2020
    
    uint MAX_GUESSES = 11;
    string[] WORDS = ["test", "hangman", "ethereum", "cryptocurrency", "foo"];
    uint wordInsertPtr;
    
    bytes internal currentWord;
    bytes internal solvedBytes;
    // hold the letters guessed for the current word
    bytes internal guessedLetters;
    uint internal guessesLeft;
    
    uint internal nextIndex;
    
    address payable private creator;
    
    constructor() public {
        creator = msg.sender;
        
        nextIndex = 0;
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
        if (WordRegex.matches(word)) {
            WORDS[wordInsertPtr] = word;
            wordInsertPtr += 1; // TODO: limit #words?
        }
    }

    function guessLetter(string memory letter) public payable {
        // check payed fee
        require(msg.value >= LETTER_GUESS_COST, string(abi.encodePacked("Please pay at least ", uint2str(LETTER_GUESS_COST), " wei")));

        bytes memory letterBytes = bytes(letter);
        // validate input
        require(letterBytes.length == 1, "You have to input only ONE lowercase letter");
        
        // add to already guessed letters - very costly :|
        bool alreadyGuessed = false;
        for (uint i = 0; i < guessedLetters2.length; i++) {
            if (guessedLetters2[i] == letterBytes[0]) // should be one byte
                alreadyGuessed = true;
        }
        if (!alreadyGuessed)
            guessedLetters2.push(letterBytes[0]);
        
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
    
    /**
     * Index Of
     *
     * Locates and returns the position of a character within a string
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string acting as the haystack to be
     *              searched
     * @param _value The needle to search for, at present this is currently
     *               limited to one character
     * @return int The position of the needle starting from 0 and returning -1
     *             in the case of no matches found
     */
    function indexOf(string memory _base, string memory _value) internal pure returns (int) {
        return _indexOf(_base, _value, 0);
    }
    function _indexOf(string memory _base, string memory _value, uint _offset) internal pure returns (int) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        assert(_valueBytes.length == 1);

        for (uint i = _offset; i < _baseBytes.length; i++) {
            if (_baseBytes[i] == _valueBytes[0]) {
                return int(i);
            }
        }

        return -1;
    }
    
     /**
     * Concat (High gas cost)
     * 
     * Appends two strings together and returns a new value
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string which will be the concatenated
     *              prefix
     * @param _value The value to be the concatenated suffix
     * @return string The resulting string from combinging the base and value
     */
    function concat(string memory _base, string memory _value) internal pure returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        assert(_valueBytes.length > 0);

        string memory _tmpValue = new string(_baseBytes.length +
            _valueBytes.length);
        bytes memory _newValue = bytes(_tmpValue);

        uint i;
        uint j;

        for (i = 0; i < _baseBytes.length; i++) {
            _newValue[j++] = _baseBytes[i];
        }

        for (i = 0; i < _valueBytes.length; i++) {
            _newValue[j++] = _valueBytes[i];
        }

        return string(_newValue);
    }
}
