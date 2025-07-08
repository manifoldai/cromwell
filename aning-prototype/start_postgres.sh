#!/bin/bash

echo "Starting PostgreSQL container for Cromwell..."

# Stop and remove existing container if it exists
docker stop cromwell-postgres 2>/dev/null || true
docker rm cromwell-postgres 2>/dev/null || true

# Start PostgreSQL container
docker run -d \
  --name cromwell-postgres \
  -e POSTGRES_DB=cromwell \
  -e POSTGRES_USER=cromwell \
  -e POSTGRES_PASSWORD=cromwell \
  -p 5432:5432 \
  -v cromwell-postgres-data:/var/lib/postgresql/data \
  postgres:15

echo "Waiting for PostgreSQL to start..."
sleep 10

# Check if PostgreSQL is ready
until docker exec cromwell-postgres pg_isready -U cromwell -d cromwell; do
  echo "Waiting for PostgreSQL to be ready..."
  sleep 2
done

echo ""
echo "✅ PostgreSQL is running!"
echo ""
echo "Connection details:"
echo "  Host: localhost"
echo "  Port: 5432"
echo "  Database: cromwell"
echo "  Username: cromwell"
echo "  Password: cromwell"
echo ""
echo "To connect via psql:"
echo "  docker exec -it cromwell-postgres psql -U cromwell -d cromwell"
echo ""
echo "To stop PostgreSQL:"
echo "  docker stop cromwell-postgres"
echo ""
echo "To view logs:"
echo "  docker logs cromwell-postgres"