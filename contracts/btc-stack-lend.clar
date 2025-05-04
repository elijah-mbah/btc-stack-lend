;; Title: BTC-Stack-Lend
;; Summary: A Bitcoin-collateralized lending protocol on Stacks Layer 2
;; Description: This smart contract enables users to deposit BTC as collateral to borrow STX, 
;; with automated health monitoring, liquidation protection, and dynamic interest rates.

;; Constants

;; Authorization
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))

;; Loan processing errors
(define-constant ERR-INSUFFICIENT-COLLATERAL (err u101))
(define-constant ERR-BELOW-MINIMUM (err u102))
(define-constant ERR-INVALID-AMOUNT (err u103))
(define-constant ERR-LOAN-NOT-FOUND (err u107))
(define-constant ERR-LOAN-NOT-ACTIVE (err u108))
(define-constant ERR-INVALID-LOAN-ID (err u109))
(define-constant ERR-INVALID-LIQUIDATION (err u106))

;; Platform state errors
(define-constant ERR-ALREADY-INITIALIZED (err u104))
(define-constant ERR-NOT-INITIALIZED (err u105))

;; Asset validation errors
(define-constant ERR-INVALID-PRICE (err u110))
(define-constant ERR-INVALID-ASSET (err u111))
(define-constant VALID-ASSETS (list "BTC" "STX"))

;; Data Variables

;; Platform Configuration
(define-data-var platform-initialized bool false)
(define-data-var minimum-collateral-ratio uint u150) ;; 150% collateral ratio
(define-data-var liquidation-threshold uint u120) ;; 120% triggers liquidation
(define-data-var platform-fee-rate uint u1) ;; 1% platform fee

;; Platform Metrics
(define-data-var total-btc-locked uint u0)
(define-data-var total-loans-issued uint u0)

;; Data Maps

;; Loan Storage
(define-map loans
    { loan-id: uint }
    {
        borrower: principal,
        collateral-amount: uint,
        loan-amount: uint,
        interest-rate: uint,
        start-height: uint,
        last-interest-calc: uint,
        status: (string-ascii 20)
    }
)

;; User Loan Tracking
(define-map user-loans
    { user: principal }
    { active-loans: (list 10 uint) }
)

;; Oracle Price Feeds
(define-map collateral-prices
    { asset: (string-ascii 3) }
    { price: uint }
)

;; Private Functions

;; Calculate the collateralization ratio (in percentage points)
(define-private (calculate-collateral-ratio (collateral uint) (loan uint) (btc-price uint))
    (let
        (
            (collateral-value (* collateral btc-price))
            (ratio (* (/ collateral-value loan) u100))
        )
        ratio
    )
)

;; Calculate accrued interest based on blocks since last calculation
(define-private (calculate-interest (principal uint) (rate uint) (blocks uint))
    (let
        (
            (interest-per-block (/ (* principal rate) (* u100 u144))) ;; Daily interest divided by blocks per day
            (total-interest (* interest-per-block blocks))
        )
        total-interest
    )
)