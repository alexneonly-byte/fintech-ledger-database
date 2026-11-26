-- ============================================================================
-- Sample Indian FinTech & UPI Seed Data (Double-Entry Ledger)
-- ============================================================================

-- 1. Insert Sample Verified Customers
INSERT INTO customers (customer_id, full_name, email, phone_number, upi_handle, kyc_status) VALUES
('11111111-1111-1111-1111-111111111111', 'Aarav Sen', 'aarav.sen@example.in', '+919830011223', 'aarav@okaxis', 'VERIFIED'),
('22222222-2222-2222-2222-222222222222', 'Ananya Das', 'ananya.das@example.in', '+919831144556', 'ananya@okhdfc', 'VERIFIED'),
('33333333-3333-3333-3333-333333333333', 'Kolkata Roasters Cafe', 'billing@kolkataroasters.in', '+919830998877', 'kolkataroasters@okicici', 'VERIFIED');

-- 2. Insert Bank Accounts (Balances in INR)
INSERT INTO accounts (account_id, customer_id, account_number, account_type, currency, balance, status) VALUES
('aaaa1111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'AXIS0009182731', 'SAVINGS', 'INR', 48500.00, 'ACTIVE'),
('bbbb2222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222', 'HDFC0004829104', 'SAVINGS', 'INR', 82000.00, 'ACTIVE'),
('cccc3333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-333333333333', 'ICIC0007741290', 'MERCHANT', 'INR', 151500.00, 'ACTIVE');

-- 3. Insert Sample UPI & IMPS Transactions
INSERT INTO transactions (transaction_id, reference_utr, sender_account_id, receiver_account_id, amount, payment_rail, status, remarks) VALUES
('99991111-1111-1111-1111-111111111111', 'UTR432198765401', 'aaaa1111-1111-1111-1111-111111111111', 'cccc3333-3333-3333-3333-333333333333', 1500.00, 'UPI', 'COMPLETED', 'Coffee & snacks bill'),
('99992222-2222-2222-2222-222222222222', 'UTR432198765402', 'bbbb2222-2222-2222-2222-222222222222', 'aaaa1111-1111-1111-1111-111111111111', 5000.00, 'IMPS', 'COMPLETED', 'Shared trip split');

-- 4. Insert Matching Double-Entry Ledger Audit Rows (Every Debit has a Credit)
INSERT INTO ledger_entries (transaction_id, account_id, entry_type, amount, balance_after) VALUES
('99991111-1111-1111-1111-111111111111', 'aaaa1111-1111-1111-1111-111111111111', 'DEBIT', 1500.00, 43500.00),
('99991111-1111-1111-1111-111111111111', 'cccc3333-3333-3333-3333-333333333333', 'CREDIT', 1500.00, 151500.00),
('99992222-2222-2222-2222-222222222222', 'bbbb2222-2222-2222-2222-222222222222', 'DEBIT', 5000.00, 82000.00),
('99992222-2222-2222-2222-222222222222', 'aaaa1111-1111-1111-1111-111111111111', 'CREDIT', 5000.00, 48500.00);
