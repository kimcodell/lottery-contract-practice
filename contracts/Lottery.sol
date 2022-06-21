// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Lottery {
  struct BetInfo {
    uint256 answerBlockNumber;
    address payable bettor;
    bytes challenges;
  }

  uint256 private _tail;
  uint256 private _haed;
  mapping (uint256 => BetInfo) private _bets;

  address public owner;

  uint256 constant internal BLOCK_LIMIT = 256;
  uint256 constant internal BET_BLOCK_INTERVAL = 3;
  uint256 constant internal BET_AMOUNT = 5 * 10 * 15;

  uint256 private _pot;

  event BET(uint256 index, address bettor, uint256 amount, bytes challenges, uint256 answerBlockNumber);
  constructor() {
    owner = msg.sender;
  }

  function getPot() public view returns (uint256) {
    return _pot;
  }

  //Bet
  /**
   * @dev 베팅 함수. 유저는 0.005이더 전송. 베티용 글자 1byte 전송.
   * @param challenges 유저가 배팅하는 글자.
   * @return result 함수 수행 결과
  */
  function bet(bytes memory challenges) public payable returns (bool result) {
    require(msg.value == BET_AMOUNT, 'Not enough ETH');

    require(pushBet(challenges), 'Fail to add a new Bet');

    emit BET(_tail - 1, msg.sender, msg.value, challenges, block.number + BET_BLOCK_INTERVAL);

    return true;
  }

  function getBetInfo(uint256 index) public view returns (uint256 answerBlockNumber, address bettor, bytes memory challenges) {
    BetInfo memory b = _bets[index];
    answerBlockNumber = b.answerBlockNumber;
    bettor = b.bettor;
    challenges = b.challenges;
  }

  function pushBet(bytes memory challenges) public returns (bool) {
    BetInfo memory b;
    b.bettor = payable(msg.sender);
    b.answerBlockNumber = block.number + BET_BLOCK_INTERVAL;
    b.challenges = challenges;

    _bets[_tail] = b;
    _tail++;

    return true;
  }

  function popBet(uint256 index) public returns (bool) {
    delete _bets[index];
    return true;
  }
}