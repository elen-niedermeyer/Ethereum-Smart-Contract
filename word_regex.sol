pragma solidity ^0.5.0;

library WordRegex {

  // poor man's solution for solidity 5+
  function matches(string memory input) public pure returns (bool) {
    for (uint i = 0; i < bytes(input).length; i++) {
      byte c = bytes(input)[i];
      if (c != "a" 
        && c != "b"
        && c != "c"
        && c != "d"
        && c != "e"
        && c != "f"
        && c != "g"
        && c != "h"
        && c != "i"
        && c != "j"
        && c != "k"
        && c != "l"
        && c != "m"
        && c != "n"
        && c != "o"
        && c != "p"
        && c != "q"
        && c != "r"
        && c != "s"
        && c != "t"
        && c != "u"
        && c != "v"
        && c != "w"
        && c != "x"
        && c != "y"
        && c != "z"
        )
        return false;
    }

    return true;
  }
}
