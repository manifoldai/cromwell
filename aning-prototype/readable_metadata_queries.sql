-- Queries to properly read CLOB metadata values in PostgreSQL
-- These convert the Large Object IDs to actual readable strings

-- Show workflow status changes over time
SELECT 
    "METADATA_KEY",
    convert_from(lo_get("METADATA_VALUE"::oid), 'UTF8') AS readable_value,
    "METADATA_VALUE_TYPE",
    "METADATA_TIMESTAMP"
FROM "METADATA_ENTRY" 
WHERE "WORKFLOW_EXECUTION_UUID" = 'e1e7ca99-14f6-405d-8ef2-ae84c6b905b6'
    AND "METADATA_KEY" = 'status'
ORDER BY "METADATA_TIMESTAMP";

-- Show execution events with readable values
SELECT 
    "METADATA_KEY",
    "CALL_FQN",
    convert_from(lo_get("METADATA_VALUE"::oid), 'UTF8') AS readable_value,
    "METADATA_TIMESTAMP"
FROM "METADATA_ENTRY" 
WHERE "WORKFLOW_EXECUTION_UUID" = 'e1e7ca99-14f6-405d-8ef2-ae84c6b905b6'
    AND "METADATA_KEY" LIKE 'executionEvents%'
ORDER BY "METADATA_TIMESTAMP";

-- Show all readable metadata for debugging
SELECT 
    "METADATA_KEY",
    "CALL_FQN",
    "JOB_SCATTER_INDEX",
    "JOB_RETRY_ATTEMPT",
    convert_from(lo_get("METADATA_VALUE"::oid), 'UTF8') AS readable_value,
    "METADATA_VALUE_TYPE",
    "METADATA_TIMESTAMP"
FROM "METADATA_ENTRY" 
WHERE "WORKFLOW_EXECUTION_UUID" = 'e1e7ca99-14f6-405d-8ef2-ae84c6b905b6'
ORDER BY "METADATA_TIMESTAMP" DESC
LIMIT 20;

-- Show workflow outputs with readable values
SELECT 
    "METADATA_KEY",
    convert_from(lo_get("METADATA_VALUE"::oid), 'UTF8') AS readable_value
FROM "METADATA_ENTRY" 
WHERE "WORKFLOW_EXECUTION_UUID" = 'e1e7ca99-14f6-405d-8ef2-ae84c6b905b6'
    AND "METADATA_KEY" LIKE 'outputs:%';

-- Show task inputs and outputs
SELECT 
    "METADATA_KEY",
    "CALL_FQN",
    convert_from(lo_get("METADATA_VALUE"::oid), 'UTF8') AS readable_value
FROM "METADATA_ENTRY" 
WHERE "WORKFLOW_EXECUTION_UUID" = 'e1e7ca99-14f6-405d-8ef2-ae84c6b905b6'
    AND ("METADATA_KEY" LIKE 'inputs:%' OR "METADATA_KEY" LIKE 'outputs:%')
ORDER BY "CALL_FQN", "METADATA_KEY";

-- Show stdout/stderr logs
SELECT 
    "METADATA_KEY",
    "CALL_FQN",
    convert_from(lo_get("METADATA_VALUE"::oid), 'UTF8') AS readable_value
FROM "METADATA_ENTRY" 
WHERE "WORKFLOW_EXECUTION_UUID" = 'e1e7ca99-14f6-405d-8ef2-ae84c6b905b6'
    AND ("METADATA_KEY" = 'stdout' OR "METADATA_KEY" = 'stderr');

-- Show command line that was executed
SELECT 
    "METADATA_KEY",
    "CALL_FQN",
    convert_from(lo_get("METADATA_VALUE"::oid), 'UTF8') AS readable_value
FROM "METADATA_ENTRY" 
WHERE "WORKFLOW_EXECUTION_UUID" = 'e1e7ca99-14f6-405d-8ef2-ae84c6b905b6'
    AND "METADATA_KEY" = 'commandLine';