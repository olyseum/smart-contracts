pragma solidity ^0.5.8;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

/**
 * @title OlyToken
 *
 * @dev Implementation of the `IERC20` interface.
 * Based on:
 * - https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.3.0/contracts/token/ERC20/ERC20.sol
 * - https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.3.0/contracts/token/ERC20/ERC20Detailed.sol
 * - https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.3.0/contracts/token/ERC20/IERC20.sol
 */
contract OlyToken is IERC20 {
    using SafeMath for uint256;

    string private _name;

    string private _symbol;

    uint8 private _decimals;

    bool private _initialized = false;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    mapping(address => mapping(uint256 => bool)) private usedNonces;

    event DeferredTransfer(
        address paymentSigner,
        uint256 nonce,
        uint256 paymentAmount,
        address paymentCollector,
        uint256 paymentFee,
        address feeCollector,
        bool statusSuccessful
    );

    /**
    * @dev Initializes the token contract
    *
    * Called by the proxy contract instead of the standard constructor
    *
    * @param name Name of the token
    * @param symbol Symbol of the token
    * @param decimals Decimals of the token
    * @param totalSupply Total supply of tokens
    * @param tokenHolder Who will receive the total supply
    */
    function initialize(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 totalSupply,
        address tokenHolder
    ) public {
        require(!_initialized, "This contract is already initialized");
        require(totalSupply > 0, "Total supply must be greater than 0");

        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _mint(tokenHolder, totalSupply);
        _initialized = true;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * > Note that this information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * `IERC20.balanceOf` and `IERC20.transfer`.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See `IERC20.totalSupply`.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See `IERC20.balanceOf`.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See `IERC20.transfer`.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See `IERC20.allowance`.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See `IERC20.approve`.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See `IERC20.transferFrom`.
     *
     * Emits an `Approval` event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of `ERC20`;
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to `transfer`, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a `Transfer` event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a `Transfer` event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destoys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a `Transfer` event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an `Approval` event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See `_burn` and `_approve`.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }

    /**
    * @dev Publishes messages signed off the chain by the user wallet.
    *
    * The transfer-message mechanism was designed to provide the wallet user a seamless
    * experience when using tokens to pay or transfer, by letting the Olyseum platform
    * to provide gas fees and executing token transactions on behalf of the user.
    *
    * Nonces are consumed always, even if the execution of a message is unsuccessful.
    * This avoids unintended replays of the message.
    *
    * @param nonces The list of nonces uniquely identifying each message in sequence.
    * @param paymentAmounts The list of payment amounts for each message.
    * @param paymentCollectors The list of payment collectors (destinations) of each message.
    * @param paymentFees The list of fees of each message.
    * @param feeCollectors The list of fee collectors of each message.
    * @param sigsR The list of r-components of the signature for each signed user message.
    * @param sigsS The list of s-components of the signature for each signed user message.
    * @param sigsV The list of v-components of the signature for each signed user message.
    */
    function publishMessages(
        uint256[] memory nonces,
        uint256[] memory paymentAmounts,
        address[] memory paymentCollectors,
        uint256[] memory paymentFees,
        address[] memory feeCollectors,
        bytes32[] memory sigsR,
        bytes32[] memory sigsS,
        uint8[] memory sigsV
    ) public {
        require(
            nonces.length == paymentAmounts.length &&
                paymentAmounts.length == paymentCollectors.length &&
                paymentCollectors.length == paymentFees.length &&
                paymentFees.length == feeCollectors.length &&
                feeCollectors.length == sigsR.length &&
                sigsR.length == sigsS.length &&
                sigsS.length == sigsV.length,
            "Inconsistent message data received"
        );

        for (uint256 i = 0; i < nonces.length; i++) {
            executeMessage(
                nonces[i],
                paymentAmounts[i],
                paymentCollectors[i],
                paymentFees[i],
                feeCollectors[i],
                sigsR[i],
                sigsS[i],
                sigsV[i]
            );
        }
    }

    /**
    * @dev Publishes a message signed off the chain by the user wallet.
    *
    * @param nonce The nonce
    * @param paymentAmount The payment amount
    * @param paymentCollector The payment collector
    * @param paymentFee The payment fee
    * @param feeCollector The fee collector
    * @param sigR The the r-value of the signature
    * @param sigS The the s-value of the signature
    * @param sigV The the v-value of the signature
    */
    function executeMessage(
        uint256 nonce,
        uint256 paymentAmount,
        address paymentCollector,
        uint256 paymentFee,
        address feeCollector,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) private {
        bytes32 hash = keccak256(
            abi.encodePacked(
                string("\x19Ethereum Signed Message:\n164Olyseum v1 Transfer Message:"),
                nonce,
                paymentAmount,
                paymentCollector,
                paymentFee,
                msg.sender
            )
        );

        address user = ecrecover(hash, sigV, sigR, sigS);
        uint256 balance = _balances[user];
        bool success = false;
        uint256 totalExpenditure = paymentAmount.add(paymentFee);

        if (
            balance >= totalExpenditure &&
            !usedNonces[user][nonce] &&
            paymentCollector != address(0) &&
            feeCollector != address(0)
        ) {
            success = true;
            usedNonces[user][nonce] = true;

            // Execute transfer
            _balances[user] = balance.sub(totalExpenditure);
            _balances[paymentCollector] = _balances[paymentCollector].add(paymentAmount);
            _balances[feeCollector] = _balances[feeCollector].add(paymentFee);

            emit Transfer(user, paymentCollector, paymentAmount);
            emit Transfer(user, feeCollector, paymentFee);
        }

        emit DeferredTransfer(
            user,
            nonce,
            paymentAmount,
            paymentCollector,
            paymentFee,
            feeCollector,
            success
        );
    }
}
