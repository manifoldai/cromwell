#!/bin/bash

echo "Connecting to Cromwell PostgreSQL database..."
echo ""

# Check if container is running
if ! docker ps | grep -q cromwell-postgres; then
    echo "❌ PostgreSQL container is not running!"
    echo "Start it first with: ./start_postgres.sh"
    exit 1
fi

echo "✅ Connecting to PostgreSQL..."
docker exec -it cromwell-postgres psql -U cromwell -d cromwell