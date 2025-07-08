-- Useful PostgreSQL queries for inspecting Cromwell database
-- Run these after connecting with ./connect_postgres.sh

-- Show all tables created by Cromwell
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- View workflow summary
SELECT 
    "WORKFLOW_EXECUTION_UUID",
    "WORKFLOW_NAME", 
    "WORKFLOW_STATUS",
    "START_TIMESTAMP",
    "END_TIMESTAMP"
FROM "WORKFLOW_METADATA_SUMMARY_ENTRY"
ORDER BY "START_TIMESTAMP" DESC;

-- Count workflows by status
SELECT 
    "WORKFLOW_STATUS",
    COUNT(*) as count
FROM "WORKFLOW_METADATA_SUMMARY_ENTRY"
GROUP BY "WORKFLOW_STATUS";

-- View recent job store entries
SELECT 
    "WORKFLOW_EXECUTION_UUID",
    "CALL_FULLY_QUALIFIED_NAME",
    "JOB_INDEX",
    "JOB_ATTEMPT",
    "JOB_SUCCESSFUL",
    "RETURN_CODE"
FROM "JOB_STORE_ENTRY"
ORDER BY "WORKFLOW_EXECUTION_UUID" DESC
LIMIT 10;

-- View metadata entries for a specific workflow
-- Replace 'WORKFLOW_ID' with actual workflow ID
-- SELECT * FROM "METADATA_ENTRY" WHERE "WORKFLOW_EXECUTION_UUID" = 'WORKFLOW_ID';

-- Show recent metadata entries
SELECT 
    "WORKFLOW_EXECUTION_UUID",
    "METADATA_KEY",
    "METADATA_VALUE"
FROM "METADATA_ENTRY"
ORDER BY "METADATA_JOURNAL_ID" DESC
LIMIT 20;

-- Show database size
SELECT pg_size_pretty(pg_database_size('cromwell')) as database_size;

-- Show table sizes
SELECT 
    table_name,
    pg_size_pretty(pg_total_relation_size(quote_ident(table_name))) as size
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY pg_total_relation_size(quote_ident(table_name)) DESC;

-- Count entries in all tables
SELECT 
    'WORKFLOW_METADATA_SUMMARY_ENTRY' as table_name,
    COUNT(*) as row_count
FROM "WORKFLOW_METADATA_SUMMARY_ENTRY"
UNION ALL
SELECT 
    'METADATA_ENTRY' as table_name,
    COUNT(*) as row_count
FROM "METADATA_ENTRY"
UNION ALL
SELECT 
    'JOB_STORE_ENTRY' as table_name,
    COUNT(*) as row_count
FROM "JOB_STORE_ENTRY"
UNION ALL
SELECT 
    'CALL_CACHING_ENTRY' as table_name,
    COUNT(*) as row_count
FROM "CALL_CACHING_ENTRY";