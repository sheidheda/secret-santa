# Secret Santa Gift Exchange Contract

This repository contains the code for a Secret Santa Gift Exchange smart contract built on the Stacks blockchain. It provides a decentralized way to organize a Secret Santa gift exchange where participants can register, pair with another participant, reveal their gift recipients, claim gifts, and withdraw their contributions before pairing. The contract ensures that all interactions are fair, transparent, and secure.

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Contract Details](#contract-details)
  - [Variables](#variables)
  - [Data Maps](#data-maps)
  - [Error Codes](#error-codes)
  - [Public Functions](#public-functions)
  - [Read-Only Functions](#read-only-functions)
- [Usage Flow](#usage-flow)
- [Security Considerations](#security-considerations)
- [Deploying and Interacting with the Contract](#deploying-and-interacting-with-the-contract)
- [Example Scenarios](#example-scenarios)
- [License](#license)

---

## Overview

This smart contract allows a group of participants to take part in a Secret Santa gift exchange by performing the following actions:
1. **Registration**: Participants can register by sending a minimum contribution in STX.
2. **Pairing**: The contract randomly pairs participants as Secret Santa givers and receivers.
3. **Gift Reveal**: Once the reveal time is reached, participants can see who they are buying a gift for.
4. **Claiming Gifts**: After the reveal time, participants can claim their gifts.
5. **Withdrawals**: Participants can withdraw their contribution before being paired.

The contract enforces several rules to ensure fairness, including a minimum contribution amount and a minimum number of participants before pairing can occur.

---

## Key Features

- **Participant Registration**: Participants can register with a STX contribution to participate in the gift exchange.
- **Secret Santa Pairing**: Participants are randomly paired once registration is complete.
- **Gift Reveal and Claiming**: Participants can reveal who they are gifting after the set reveal time and claim their gift from their Secret Santa.
- **Contribution Withdrawal**: Participants can withdraw their contributions if they have not yet been paired.
- **Security**: Only the contract owner can pair participants. Only registered participants can reveal or claim gifts.

---

## Contract Details

### Variables

- **registration-open**: Boolean variable indicating whether registration is open. If closed, new participants cannot register.
- **reveal-time**: The specific time (timestamp) after which participants can reveal their gift recipients and claim gifts.
- **minimum-participants**: The minimum number of participants required to start pairing.
- **minimum-contribution**: The minimum STX amount required to register as a participant.
- **participant-count**: Tracks the number of participants currently registered.
- **current-pair-index**: Tracks the current index of participants for pairing.

### Data Maps

- **participants**: Stores information about each participant, including their registration status, contribution, pairing status, and gift claim status.
- **participant-indices**: Maps participant indices to their principal address.
- **santa-pairs**: Maps a giver (Secret Santa) to a receiver (the person they are gifting).
- **gift-receivers**: Maps a receiver to their Secret Santa giver.

### Error Codes

The contract uses the following error codes for various failure conditions:

- **err-not-authorized**: Raised when an unauthorized user attempts an action that requires special privileges (e.g., pairing).
- **err-already-registered**: Raised when a participant tries to register multiple times.
- **err-invalid-amount**: Raised when a participant’s contribution is below the required minimum.
- **err-not-registered**: Raised when an action is performed by a non-registered participant.
- **err-already-paired**: Raised when a participant has already been paired.
- **err-not-reveal-time**: Raised when a participant tries to reveal or claim a gift before the reveal time.
- **err-already-claimed**: Raised when a participant attempts to claim their gift multiple times.
- **err-not-enough-participants**: Raised when there are not enough participants to begin pairing.
- **err-pairing-failed**: Raised if pairing fails due to some unexpected condition.

### Public Functions

1. **register-participant(contribution)**: Allows participants to register by contributing a minimum amount of STX.
   - Conditions: Must not already be registered, contribution must meet the minimum, and registration must be open.
   - Transfers the STX contribution to the contract owner.

2. **pair-single-participant()**: Pairs participants by randomly assigning them as Secret Santa givers and receivers.
   - Can only be called by the contract owner.
   - Stops pairing once all participants are paired and registration is closed.

3. **reveal-gift()**: Allows participants to reveal who they are buying a gift for, after the reveal time.
   - Only works if the participant is registered and paired.

4. **claim-gift()**: Allows participants to claim their gift after the reveal time.
   - Transfers the gift amount from the giver to the receiver and updates the participant's claim status.

5. **withdraw-contribution()**: Allows participants to withdraw their contribution before they are paired.
   - Deletes the participant’s record and updates the participant count.

### Read-Only Functions

1. **get-participant-info(participant)**: Retrieves the information about a specific participant.
2. **is-contract-owner()**: Checks if the caller is the contract owner.
3. **get-participant-count()**: Returns the total number of registered participants.
4. **get-current-pair-index()**: Returns the current index for pairing.

---

## Usage Flow

1. **Registration**: Participants call `register-participant(contribution)` to register for the Secret Santa event.
2. **Pairing**: The contract owner calls `pair-single-participant()` to randomly pair participants.
3. **Reveal**: After the set `reveal-time`, participants can call `reveal-gift()` to discover who they are gifting.
4. **Claim**: Participants can then call `claim-gift()` to receive their gift from their Secret Santa.
5. **Withdraw**: Before pairing occurs, participants can call `withdraw-contribution()` to get their STX contribution back.

---

## Security Considerations

- **Owner Privileges**: Only the contract owner can initiate participant pairing.
- **Participant Registration**: Only registered participants can participate in the gift exchange. Unauthorized calls to pair or reveal gifts are prevented.
- **Timing**: Gift claims and reveals are restricted to after the `reveal-time`, preventing early access to gifts.
- **Withdrawals**: Participants can withdraw their contributions before pairing, ensuring that no one is forced into the exchange if they decide not to participate.

---

## Deploying and Interacting with the Contract

To deploy and interact with this contract, follow these steps:

1. **Deploy the Contract**: Use the Stacks CLI or a smart contract deployment service to deploy the contract to the Stacks blockchain.
2. **Interact via CLI**: Once deployed, use the Stacks CLI to interact with the contract. You can register participants, pair them, reveal gifts, claim gifts, and withdraw contributions.
3. **Web Interface**: You can build a front-end application to interact with this contract using the Stacks.js library, allowing participants to register and participate in the Secret Santa gift exchange directly from a web browser.

---

## Example Scenarios

1. **Participant Registers**: A participant sends a contribution of 100 STX to register. If they are the first participant, they are added to the list.
2. **Pairing**: The contract owner calls `pair-single-participant()` to randomly assign a Secret Santa giver and receiver for each participant.
3. **Gift Reveal**: After the reveal time, participants can call `reveal-gift()` to find out who they are gifting to.
4. **Claim Gift**: Participants can claim their gift after the reveal time by calling `claim-gift()`.
5. **Withdraw**: Before pairing, a participant decides to withdraw their contribution and calls `withdraw-contribution()`.

---

## License

This contract is licensed under the MIT License. See the LICENSE file for more information.