#!/bin/bash

echo "=== PostgreSQL Database Debug ==="
echo ""

# Check if PostgreSQL container is running
if ! docker ps | grep -q cromwell-postgres; then
    echo "❌ PostgreSQL container is not running!"
    exit 1
fi

echo "✅ PostgreSQL container is running"
echo ""

# Connect to database and run diagnostics
docker exec -i cromwell-postgres psql -U cromwell -d cromwell << 'EOF'
-- Show all tables
\dt

-- Show workflow metadata summary
SELECT 
    "WORKFLOW_EXECUTION_UUID",
    "WORKFLOW_NAME",
    "WORKFLOW_STATUS",
    "START_TIMESTAMP",
    "END_TIMESTAMP"
FROM "WORKFLOW_METADATA_SUMMARY_ENTRY"
ORDER BY "START_TIMESTAMP" DESC;

-- Count total entries in key tables
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

-- Show recent metadata entries
SELECT 
    "WORKFLOW_EXECUTION_UUID",
    "METADATA_KEY",
    "METADATA_VALUE"
FROM "METADATA_ENTRY"
ORDER BY "METADATA_JOURNAL_ID" DESC
LIMIT 10;

-- Show job store entries
SELECT 
    "WORKFLOW_EXECUTION_UUID",
    "JOB_KEY",
    "JOB_STATE",
    "ATTEMPT",
    "RETURN_CODE"
FROM "JOB_STORE_ENTRY"
ORDER BY "WORKFLOW_EXECUTION_UUID" DESC;

EOF