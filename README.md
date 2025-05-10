# BTC-Stack-Lend

**A Bitcoin-collateralized lending protocol on the Stacks Layer 2**
Securely borrow STX by locking BTC, powered by Clarity smart contracts and on-chain automation.

## Overview

**BTC-Stack-Lend** is a decentralized lending protocol built on the Stacks blockchain. It enables users to deposit **Bitcoin (BTC)** as collateral and borrow **Stacks Token (STX)**. The protocol ensures solvency and risk management through:

* Dynamic interest rates
* Real-time loan health monitoring
* Automated liquidation mechanisms
* Governance-controlled parameters

By leveraging Stacks’ Clarity smart contracts and Bitcoin’s security, BTC-Stack-Lend enables trust-minimized, non-custodial lending directly secured by BTC.

## Key Features

* **Bitcoin-Backed Loans**: Use BTC as trustless collateral to borrow STX.
* **Collateral Ratio Enforcement**: Loans must maintain a minimum collateral ratio (default: 150%).
* **Auto-Liquidation**: Loans falling below 120% collateralization are automatically liquidated.
* **Dynamic Interest Accrual**: Interest is calculated based on block height and loan age.
* **Governance Configurable**: Core protocol parameters (ratios, rates, price feeds) are upgradable by the contract owner.

## Architecture & Components

### Smart Contract Constants

* **CONTRACT-OWNER**: Only this address can perform admin operations.
* **VALID-ASSETS**: Supported assets — currently `"BTC"` and `"STX"`.
* **Error Codes**: Standardized error constants for all validation and logic paths.

### Persistent Storage

* `loans`: Core data map storing all loan records by `loan-id`.
* `user-loans`: Tracks active loans for each user (up to 10).
* `collateral-prices`: Oracle-like price feeds for BTC and other assets.
* `platform-initialized`: One-time flag to prevent reinitialization.
* `total-btc-locked`: Aggregate BTC collateral in the system.
* `total-loans-issued`: Tracks cumulative loan count.

### Key Functions

#### Public Functions

* `initialize-platform`: Initializes protocol. One-time use by `CONTRACT-OWNER`.
* `deposit-collateral(amount)`: Adds BTC collateral to system metrics.
* `request-loan(collateral, loan-amount)`: Opens a new loan if the collateral ratio is sufficient.
* `repay-loan(loan-id, amount)`: Fully repays loan plus accrued interest, returns BTC collateral.
* `update-collateral-ratio(new-ratio)`: Governance function to adjust required collateral ratio.
* `update-liquidation-threshold(new-threshold)`: Sets threshold below which liquidation is triggered.
* `update-price-feed(asset, new-price)`: Updates asset price feeds.

#### Read-Only Functions

* `get-loan-details(loan-id)`: Returns details of a specific loan.
* `get-user-loans(user)`: Fetches active loan list for a given user.
* `get-platform-stats()`: Returns core platform statistics.
* `get-valid-assets()`: Lists assets recognized by the platform.

#### Private Functions

* `calculate-collateral-ratio`: Derives collateral ratio using BTC price and loan amount.
* `calculate-interest`: Computes block-based interest accrued since last calculation.
* `check-liquidation`: Triggers liquidation logic if ratio falls below the threshold.
* `liquidate-position`: Sets loan to "liquidated", burns collateral.
* Validation helpers: Asset, price, and loan ID validators.

## Technical Considerations

* **Interest Rate Calculation**: Uses block height and a fixed per-loan interest rate (e.g., 5%) adjusted for expected block-per-day (144).
* **Liquidation Logic**: Fully automatic and enforced on-chain, with hard-coded thresholds configurable by governance.
* **Data Map Safety**: Uses pattern-matching, optionals, and Clarity's `unwrap!` to enforce safe map access.
* **Max Active Loans**: Limited to 10 active loans per user for performance and safety.

## Security Model

* **Owner Controls**: Only `CONTRACT-OWNER` can initialize and update parameters.
* **No Custody of BTC**: BTC collateral is tracked via metric; assumes BTC anchoring mechanism (e.g., wrapped BTC on Stacks or cross-chain communication).
* **Safe Loan Management**: Loans cannot be repaid by third parties; access restricted to borrowers.
* **Collateralization Enforcement**: Core logic prevents undercollateralized loan creation.

## Future Improvements

* Integration with decentralized oracles for price feeds
* Collateral tokenization and secondary markets
* Partial repayment and top-up mechanisms
* Multi-collateral support with dynamic weighting
* Automated liquidation bots or auction system

## Example Workflow

1. **Platform Initialization**:

   ```clarity
   (initialize-platform)
   ```

2. **Update Price Feed**:

   ```clarity
   (update-price-feed "BTC" u30000)
   ```

3. **Deposit Collateral**:

   ```clarity
   (deposit-collateral u1000)
   ```

4. **Request Loan**:

   ```clarity
   (request-loan u1000 u150)
   ```

5. **Repay Loan**:

   ```clarity
   (repay-loan u1 u160)
   ```

## Resources

* [Stacks Documentation](https://docs.stacks.co/)
* [Clarity Language Reference](https://docs.stacks.co/docs/clarity)
* [Bitcoin on Stacks](https://www.stacks.co/bitcoin)
