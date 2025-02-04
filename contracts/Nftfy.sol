// Nftfy
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.6.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import { Wrapper, ERC721Wrapper } from "./Wrapper.sol";
import { Shares, ERC721Shares } from "./Shares.sol";

contract Nftfy
{
	mapping (IERC721 => bool) wraps;
	mapping (IERC721 => ERC721Wrapper) public wrappers;

	function ensureWrapper(IERC721 _target) public returns (ERC721Wrapper _wrapper)
	{
		require(!wraps[_target]);
		_wrapper = wrappers[_target];
		if (_wrapper == ERC721Wrapper(0)) {
			_wrapper = Wrapper.create(_target);
			wrappers[_target] = _wrapper;
			wraps[_wrapper] = true;
		}
		return _wrapper;
	}

	function securitize(IERC721 _target, uint256 _tokenId, uint256 _sharesCount, uint8 _decimals, uint256 _exitPrice, IERC20 _paymentToken, bool _remnant) public
	{
		address _from = msg.sender;
		ERC721Wrapper _wrapper = ensureWrapper(_target);
		require(_exitPrice > 0);
		require(_sharesCount > 0);
		require(_exitPrice % _sharesCount == 0);
		uint256 _sharePrice = _exitPrice / _sharesCount;
		ERC721Shares _shares = Shares.create(_wrapper, _tokenId, _from, _sharesCount, _decimals, _sharePrice, _paymentToken, _remnant);
		_target.transferFrom(_from, address(_shares), _tokenId);
		_wrapper._insert(_from, _tokenId, _remnant, _shares);
	}
}
