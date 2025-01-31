;; Bitcoin Battle Game
;; A blockchain game with Bitcoin rewards

(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u101))
(define-constant ERR-GAME-NOT-FOUND (err u102))
(define-constant ERR-INVALID-STATE (err u103))
(define-constant ERR-INSUFFICIENT-FUNDS (err u104))
(define-constant ERR-ALREADY-JOINED (err u105))
(define-constant ERR-NOT-PLAYER (err u106))
(define-constant MIN-STAKE u1000000) ;; Minimum stake in microSTX

;; Character Types
(define-constant TYPE-WARRIOR u1)
(define-constant TYPE-MAGE u2)
(define-constant TYPE-ARCHER u3)

;; Game States
(define-constant STATE-OPEN u1)
(define-constant STATE-IN-PROGRESS u2)
(define-constant STATE-COMPLETED u3)

;; Data Maps
(define-map games
    {game-id: uint}
    {
        creator: principal,
        stake: uint,
        btc-reward: uint,
        state: uint,
        player1: (optional principal),
        player2: (optional principal),
        winner: (optional principal),
        created-at: uint,
        last-move: uint
    }
)

(define-map characters
    {game-id: uint, player: principal}
    {
        char-type: uint,
        health: uint,
        attack: uint,
        defense: uint,
        special-moves: uint
    }
)