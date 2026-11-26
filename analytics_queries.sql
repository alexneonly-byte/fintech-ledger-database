-- ============================================================================
-- FinTech Analytics & Audit Verification Queries (PostgreSQL)
-- ============================================================================

-- 1. Customer Portfolio & Total INR Balance Summary
SELECT 
    c.full_name,
    c.upi_handle,
    a.account_number,
    a.account_type,
    a.balance AS current_balance_inr
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
WHERE a.status = 'ACTIVE'
ORDER BY a.balance DESC;

-- 2. Double-Entry Ledger Integrity Check (Total Debits MUST equal Total Credits)
SELECT 
    entry_type,
    COUNT(*) AS total_entries,
    SUM(amount) AS total_volume_inr
FROM ledger_entries
GROUP BY entry_type;

-- 3. Payment Rail Breakdown (UPI vs IMPS Volume & Average Ticket Size)
SELECT 
    payment_rail,
    COUNT(transaction_id) AS transaction_count,
    SUM(amount) AS total_transferred_inr,
    ROUND(AVG(amount), 2) AS avg_transaction_inr
FROM transactions
WHERE status = 'COMPLETED'
GROUP BY payment_rail
ORDER BY total_transferred_inr DESC;

-- 4. Full Account Statement / Passbook View with Running Balance
SELECT 
    c.full_name,
    t.reference_utr,
    t.payment_rail,
    le.entry_type,
    le.amount,
    le.balance_after,
    t.remarks,
    le.recorded_at
FROM ledger_entries le
JOIN accounts a ON le.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
JOIN transactions t ON le.transaction_id = t.transaction_id
ORDER BY le.recorded_at DESC;
