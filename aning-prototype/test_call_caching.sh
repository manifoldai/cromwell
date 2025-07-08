#!/bin/bash

set -e

# Configuration
CROMWELL_URL="http://localhost:8000"
WDL_FILE="call_caching_demo.wdl"
INPUTS_FILE="call_caching_inputs.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Cromwell is running
check_cromwell() {
    print_status "Checking if Cromwell is running..."
    if curl -s "$CROMWELL_URL/api/workflows/v1/version" > /dev/null; then
        print_success "Cromwell is running"
        return 0
    else
        print_error "Cromwell is not running at $CROMWELL_URL"
        return 1
    fi
}

# Function to submit workflow
submit_workflow() {
    local run_name=$1
    print_status "Submitting workflow: $run_name"
    
    local response=$(curl -s -X POST \
        -H "Content-Type: multipart/form-data" \
        -F "workflowSource=@$WDL_FILE" \
        -F "workflowInputs=@$INPUTS_FILE" \
        "$CROMWELL_URL/api/workflows/v1")
    
    local workflow_id=$(echo "$response" | jq -r '.id')
    
    if [ "$workflow_id" = "null" ] || [ -z "$workflow_id" ]; then
        print_error "Failed to submit workflow"
        echo "$response" | jq .
        return 1
    fi
    
    print_success "Workflow submitted: $workflow_id"
    echo "$workflow_id"
}

# Function to wait for workflow completion
wait_for_completion() {
    local workflow_id=$1
    print_status "Waiting for workflow $workflow_id to complete..."
    
    while true; do
        local status=$(curl -s "$CROMWELL_URL/api/workflows/v1/$workflow_id/status" | jq -r '.status')
        
        case "$status" in
            "Succeeded")
                print_success "Workflow completed successfully"
                return 0
                ;;
            "Failed"|"Aborted")
                print_error "Workflow failed with status: $status"
                return 1
                ;;
            "Running"|"Submitted")
                print_status "Workflow status: $status"
                sleep 10
                ;;
            *)
                print_status "Workflow status: $status"
                sleep 5
                ;;
        esac
    done
}

# Function to get workflow timing
get_workflow_timing() {
    local workflow_id=$1
    print_status "Getting timing information for workflow $workflow_id"
    
    curl -s "$CROMWELL_URL/api/workflows/v1/$workflow_id/timing" | jq '.'
}

# Function to check call caching in metadata
check_call_caching() {
    local workflow_id=$1
    print_status "Checking call caching metadata for workflow $workflow_id"
    
    local metadata=$(curl -s "$CROMWELL_URL/api/workflows/v1/$workflow_id/metadata")
    
    # Check for cache hits
    local cache_hits=$(echo "$metadata" | jq -r '.calls | to_entries[] | .value[] | select(.callCaching.hit == true) | .callRoot')
    
    if [ -n "$cache_hits" ]; then
        print_success "Found call cache hits:"
        echo "$cache_hits"
        return 0
    else
        print_warning "No call cache hits found"
        return 1
    fi
}

# Function to query call caching database
query_call_caching_db() {
    local workflow_id=$1
    print_status "Querying call caching database for workflow $workflow_id"
    
    # This would need to be run against your PostgreSQL database
    echo "Run this query against your PostgreSQL database:"
    echo "SELECT * FROM \"CALL_CACHING_ENTRY\" WHERE \"WORKFLOW_EXECUTION_UUID\" = '$workflow_id';"
}

# Main execution
main() {
    print_status "Starting call caching demonstration"
    
    # Check if required files exist
    if [ ! -f "$WDL_FILE" ]; then
        print_error "WDL file not found: $WDL_FILE"
        exit 1
    fi
    
    if [ ! -f "$INPUTS_FILE" ]; then
        print_error "Inputs file not found: $INPUTS_FILE"
        exit 1
    fi
    
    # Check Cromwell
    if ! check_cromwell; then
        exit 1
    fi
    
    # First run
    print_status "=== FIRST RUN (should create cache entries) ==="
    workflow_id_1=$(submit_workflow "First Run")
    if [ $? -ne 0 ]; then
        exit 1
    fi
    
    if ! wait_for_completion "$workflow_id_1"; then
        exit 1
    fi
    
    print_status "First run completed. Workflow ID: $workflow_id_1"
    
    # Second run (should use cache)
    print_status "=== SECOND RUN (should use cache) ==="
    workflow_id_2=$(submit_workflow "Second Run")
    if [ $? -ne 0 ]; then
        exit 1
    fi
    
    if ! wait_for_completion "$workflow_id_2"; then
        exit 1
    fi
    
    print_status "Second run completed. Workflow ID: $workflow_id_2"
    
    # Check caching results
    print_status "=== ANALYZING CALL CACHING RESULTS ==="
    
    print_status "Checking cache hits in second run:"
    check_call_caching "$workflow_id_2"
    
    print_status "Timing comparison:"
    print_status "First run timing:"
    get_workflow_timing "$workflow_id_1"
    
    print_status "Second run timing:"
    get_workflow_timing "$workflow_id_2"
    
    print_status "Database query for call caching entries:"
    query_call_caching_db "$workflow_id_1"
    query_call_caching_db "$workflow_id_2"
    
    print_success "Call caching demonstration completed!"
    print_status "Workflow IDs:"
    print_status "  First run:  $workflow_id_1"
    print_status "  Second run: $workflow_id_2"
}

# Run main function
main "$@"