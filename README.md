# Bitcoin Battle Game

A blockchain-based battle game with Bitcoin rewards, built on the Stacks blockchain. Players can create characters, battle other players, and win rewards in both STX and BTC.

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Technical Architecture](#technical-architecture)
- [Getting Started](#getting-started)
- [Game Mechanics](#game-mechanics)
- [Development](#development)
- [Testing](#testing)
- [Deployment](#deployment)
- [Security](#security)

## Overview

Bitcoin Battle Game is a turn-based battle game where players can:
- Create different character types (Warrior, Mage, Archer)
- Stake STX to participate in battles
- Win Bitcoin rewards for victories
- Execute special moves and strategies
- Track game history on-chain

## Features

### Character System
- Three unique character types:
  - Warrior: High defense, balanced attack
  - Mage: High attack, low defense
  - Archer: Balanced stats, special abilities

### Battle Mechanics
- Turn-based combat system
- Special moves and abilities
- Health and damage calculation
- Strategic gameplay elements

### Reward System
- STX staking mechanism
- Bitcoin reward distribution
- Automated payouts
- Verifiable game outcomes

## Technical Architecture

### Smart Contract Structure
```plaintext
bitcoin-game/
├── contracts/
│   ├── bitcoin-game.clar        # Main game contract
│   └── traits/
│       └── ft-trait.clar        # Token standards
├── tests/
│   └── bitcoin-game_test.ts     # Test suite
└── client/
    └── src/
        ├── components/          # React components
        └── lib/                 # Utility functions
```

## Getting Started

### Prerequisites
```bash
# Install Clarinet
curl -L https://github.com/hirosystems/clarinet/releases/download/v1.0.0/clarinet-linux-x64-glibc.tar.gz | tar xz

# Install dependencies
npm install
```

### Local Development
```bash
# Start local Clarinet chain
clarinet integrate

# Run development server
npm run dev
```

## Game Mechanics

### Creating a Game
1. Select character type
2. Stake minimum required STX
3. Wait for opponent to join

### Joining a Game
1. Select available game
2. Choose character type
3. Match stake amount
4. Start battle

### Battle System
1. Turn-based moves
2. Calculate damage based on:
   - Character stats
   - Move type
   - Defense values
3. Special abilities usage
4. Victory conditions

### Reward Distribution
1. Winner receives:
   - Combined STX stake
   - Bitcoin reward
2. Automated payout system
3. Verifiable on both chains

## Development

### Smart Contract Functions

#### Core Functions
```clarity
(define-public (create-game (stake uint) (char-type uint)))
(define-public (join-game (game-id uint) (char-type uint)))
(define-public (make-move (game-id uint) (move-type uint)))
```

#### Helper Functions
```clarity
(define-private (calculate-damage (move-type uint) (attacker {char-type: uint, ...})))
(define-private (distribute-rewards (game-id uint) (winner principal)))
```

### Testing

```bash
# Run all tests
clarinet test

# Run specific test file
clarinet test tests/bitcoin-game_test.ts
```

## Deployment

### Testnet Deployment
```bash
# Deploy contract
clarinet deploy --testnet

# Verify deployment
stx call get-game 1
```

### Mainnet Deployment
```bash
# Deploy contract
clarinet deploy --mainnet

# Set up reward distribution
stx contract_call setup-rewards
```

## Security

### Security Measures
1. Stake verification
2. Move validation
3. State management
4. Access control
5. Reward protection

### Best Practices
- Verify all transactions
- Monitor game states
- Handle errors properly
- Implement timeouts
- Validate inputs

## Client Integration

### React Components
```javascript
// Game creation
<GameCreator onSubmit={createGame} />

// Active game
<GameBoard game={selectedGame} onMove={makeMove} />

// Game list
<GameList games={games} onJoin={joinGame} />
```

### Contract Interaction
```javascript
// Create game
const createGame = async (characterType) => {
    await doContractCall({
        contractAddress,
        contractName,
        functionName: 'create-game',
        functionArgs: [stake, characterType]
    });
};
```

## Contributing

1. Fork repository
2. Create feature branch
3. Commit changes
4. Submit pull request

## License

MIT License - See LICENSE file