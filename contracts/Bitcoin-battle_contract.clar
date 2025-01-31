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

(define-map game-moves
    {game-id: uint, move-number: uint}
    {
        player: principal,
        move-type: uint,
        damage: uint,
        timestamp: uint
    }
)

;; Variables
(define-data-var game-counter uint u0)
(define-data-var btc-height uint u0)

;; Read-only functions
(define-read-only (get-game (game-id uint))
    (map-get? games {game-id: game-id})
)

(define-read-only (get-character (game-id uint) (player principal))
    (map-get? characters {game-id: game-id, player: player})
)

;; Game creation and joining
(define-public (create-game (stake uint) (char-type uint))
    (let (
        (game-id (+ (var-get game-counter) u1))
        (reward (* stake u2)) ;; Double the stake as BTC reward
    )
        ;; Check minimum stake
        (asserts! (>= stake MIN-STAKE) ERR-INSUFFICIENT-FUNDS)
        ;; Check valid character type
        (asserts! (or (is-eq char-type TYPE-WARRIOR) 
                     (is-eq char-type TYPE-MAGE)
                     (is-eq char-type TYPE-ARCHER)) ERR-INVALID-STATE)
        
        ;; Transfer stake to contract
        (try! (stx-transfer? stake tx-sender (as-contract tx-sender)))
        
        ;; Create game
        (map-set games
            {game-id: game-id}
            {
                creator: tx-sender,
                stake: stake,
                btc-reward: reward,
                state: STATE-OPEN,
                player1: (some tx-sender),
                player2: none,
                winner: none,
                created-at: block-height,
                last-move: block-height
            }
        )
        
        ;; Create character
        (map-set characters
            {game-id: game-id, player: tx-sender}
            (get-initial-stats char-type)
        )
        
        (var-set game-counter game-id)
        (ok game-id)
    )
)

;; Game mechanics
(define-public (make-move (game-id uint) (move-type uint))
    (let (
        (game (unwrap! (map-get? games {game-id: game-id}) ERR-GAME-NOT-FOUND))
        (player-char (unwrap! (map-get? characters {game-id: game-id, player: tx-sender}) 
            ERR-NOT-PLAYER))
    )
        ;; Verify game state
        (asserts! (is-eq (get state game) STATE-IN-PROGRESS) ERR-INVALID-STATE)
        (asserts! (is-current-player game-id tx-sender) ERR-NOT-AUTHORIZED)
        
        ;; Calculate damage
        (let (
            (damage (calculate-damage move-type player-char))
            (opponent (get-opponent game tx-sender))
            (opponent-char (unwrap! (map-get? characters 
                {game-id: game-id, player: opponent}) ERR-NOT-PLAYER))
        )
            ;; Apply damage
            (try! (apply-damage game-id opponent damage))
            
            ;; Record move
            (map-set game-moves
                {game-id: game-id, move-number: (get-move-count game-id)}
                {
                    player: tx-sender,
                    move-type: move-type,
                    damage: damage,
                    timestamp: block-height
                }
            )
            
            ;; Check for game end
            (if (is-game-over opponent-char)
                (distribute-rewards game-id tx-sender)
                (ok true)
            )
        )
    )
)

;; Helper functions
(define-private (get-initial-stats (char-type uint))
    (match char-type
        TYPE-WARRIOR {char-type: TYPE-WARRIOR, health: u100, attack: u15, defense: u10, special-moves: u3}
        TYPE-MAGE {char-type: TYPE-MAGE, health: u80, attack: u20, defense: u5, special-moves: u5}
        TYPE-ARCHER {char-type: TYPE-ARCHER, health: u90, attack: u18, defense: u7, special-moves: u4}
    )
)

(define-private (calculate-damage (move-type uint) (attacker {char-type: uint, health: uint, attack: uint, defense: uint, special-moves: uint}))
    (let (
        (base-damage (get attack attacker))
    )
        (if (is-eq move-type u2)
            (* base-damage u2) ;; Special move
            base-damage
        )
    )
)

(define-private (apply-damage (game-id uint) (defender principal) (damage uint))
    (let (
        (defender-char (unwrap! (map-get? characters {game-id: game-id, player: defender})
            ERR-NOT-PLAYER))
        (new-health (- (get health defender-char) damage))
    )
        (map-set characters
            {game-id: game-id, player: defender}
            (merge defender-char {health: new-health})
        )
        (ok true)
    )
)

(define-private (is-game-over (character {char-type: uint, health: uint, attack: uint, defense: uint, special-moves: uint}))
    (<= (get health character) u0)
)

(define-private (distribute-rewards (game-id uint) (winner principal))
    (let (
        (game (unwrap! (map-get? games {game-id: game-id}) ERR-GAME-NOT-FOUND))
        (total-reward (* (get stake game) u2))
    )
        ;; Update game state
        (map-set games
            {game-id: game-id}
            (merge game {
                state: STATE-COMPLETED,
                winner: (some winner)
            })
        )
        
        ;; Transfer STX reward
        (try! (as-contract (stx-transfer? total-reward tx-sender winner)))
        
        ;; Request BTC reward (would be handled by separate mechanism)
        (ok true)
    )
)