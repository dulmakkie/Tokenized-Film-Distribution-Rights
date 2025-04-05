# Tokenized Film Distribution Rights System

A blockchain-based system for managing film distribution rights, tracking revenue, and distributing royalties using smart contracts.

## Overview

This project implements a comprehensive solution for tokenizing and managing film distribution rights on the blockchain. It enables content creators and distributors to verify ownership, manage territorial rights, track revenue, and distribute royalties in a transparent and automated way.

## Smart Contracts

The system consists of four main smart contracts:

### 1. Content Verification Contract

This contract handles the registration and verification of film properties:

- Register new films with metadata and content hash
- Verify film authenticity
- Transfer ownership of film rights
- Query film verification status

### 2. Territory Rights Contract

This contract manages distribution permissions by geographic region:

- Define territory codes
- Grant distribution rights for specific territories
- Support for exclusive and non-exclusive rights
- Validate distribution authorization

### 3. Revenue Tracking Contract

This contract monitors income from various distribution channels:

- Define revenue channels (streaming, theatrical, etc.)
- Record revenue by film, channel, and territory
- Verify revenue records
- Track total revenue by film

### 4. Royalty Distribution Contract

This contract handles the allocation of payments to rights holders:

- Define royalty allocation percentages
- Process royalty payments
- Track payment status
- Query payment records

## Usage

### Prerequisites

- Clarity contract deployment environment
- Stacks blockchain access

### Deployment

1. Deploy the Content Verification contract first
2. Deploy the Territory Rights contract
3. Deploy the Revenue Tracking contract
4. Deploy the Royalty Distribution contract

### Basic Workflow

1. Register a film using the Content Verification contract
2. Verify the film's authenticity
3. Set up territory rights for different regions
4. Define royalty allocation percentages
5. Record revenue as it comes in
6. Process royalty payments based on the defined allocations

## Testing

Tests are implemented using Vitest. To run the tests:

```bash
npm test
