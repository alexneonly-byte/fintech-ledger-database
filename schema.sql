-- FinTech Double-Entry Ledger & UPI Payment Database Schema (PostgreSQL)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Customers Table (KYC & Profile)
CREATE TABLE customers (
    customer_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    upi_handle VARCHAR(60) UNIQUE NOT NULL,
    kyc_status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (kyc_status IN ('PENDING', 'VERIFIED', 'REJECTED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Bank Accounts Table
CREATE TABLE accounts (
    account_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES customers(customer_id) ON DELETE RESTRICT,
    account_number VARCHAR(20) UNIQUE NOT NULL,
    account_type VARCHAR(20) NOT NULL CHECK (account_type IN ('SAVINGS', 'CURRENT', 'MERCHANT')),
    currency CHAR(3) NOT NULL DEFAULT 'INR',
    balance NUMERIC(15, 2) NOT NULL DEFAULT 0.00 CHECK (balance >= 0.00),
    status VARCHAR(15) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'FROZEN', 'CLOSED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Transactions Table (High-level payment record)
CREATE TABLE transactions (
    transaction_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_utr VARCHAR(32) UNIQUE NOT NULL,
    sender_account_id UUID NOT NULL REFERENCES accounts(account_id),
    receiver_account_id UUID NOT NULL REFERENCES accounts(account_id),
    amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0.00),
    payment_rail VARCHAR(20) NOT NULL CHECK (payment_rail IN ('UPI', 'IMPS', 'NEFT', 'RTGS')),
    status VARCHAR(20) NOT NULL DEFAULT 'COMPLETED' CHECK (status IN ('PENDING', 'COMPLETED', 'FAILED', 'FLAGGED')),
    remarks VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_different_accounts CHECK (sender_account_id <> receiver_account_id)
);

-- 4. Double-Entry Ledger Entries (Immutable audit trail)
CREATE TABLE ledger_entries (
    entry_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_id UUID NOT NULL REFERENCES transactions(transaction_id),
    account_id UUID NOT NULL REFERENCES accounts(account_id),
    entry_type VARCHAR(10) NOT NULL CHECK (entry_type IN ('DEBIT', 'CREDIT')),
    amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0.00),
    balance_after NUMERIC(15, 2) NOT NULL,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. Performance Indexes for Fast Lookups & Fraud Checks
CREATE INDEX idx_customers_upi ON customers(upi_handle);
CREATE INDEX idx_accounts_customer ON accounts(customer_id);
CREATE INDEX idx_transactions_sender_time ON transactions(sender_account_id, created_at DESC);
CREATE INDEX idx_transactions_receiver_time ON transactions(receiver_account_id, created_at DESC);
CREATE INDEX idx_ledger_account_history ON ledger_entries(account_id, recorded_at DESC);
