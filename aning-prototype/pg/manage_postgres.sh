#!/bin/bash

case "$1" in
    start)
        ./start_postgres.sh
        ;;
    stop)
        echo "Stopping PostgreSQL container..."
        docker stop cromwell-postgres
        ;;
    restart)
        echo "Restarting PostgreSQL container..."
        docker restart cromwell-postgres
        ;;
    logs)
        echo "Showing PostgreSQL logs..."
        docker logs -f cromwell-postgres
        ;;
    connect)
        ./connect_postgres.sh
        ;;
    status)
        echo "PostgreSQL container status:"
        docker ps | grep cromwell-postgres || echo "Container not running"
        if docker ps | grep -q cromwell-postgres; then
            echo ""
            echo "Database connection test:"
            docker exec cromwell-postgres pg_isready -U cromwell -d cromwell
        fi
        ;;
    clean)
        echo "⚠️  This will DELETE ALL DATA in the PostgreSQL container!"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker stop cromwell-postgres 2>/dev/null || true
            docker rm cromwell-postgres 2>/dev/null || true
            docker volume rm cromwell-postgres-data 2>/dev/null || true
            echo "✅ PostgreSQL container and data cleaned"
        else
            echo "Cancelled"
        fi
        ;;
    *)
        echo "Cromwell PostgreSQL Management Script"
        echo ""
        echo "Usage: $0 {start|stop|restart|logs|connect|status|clean}"
        echo ""
        echo "Commands:"
        echo "  start    - Start PostgreSQL container"
        echo "  stop     - Stop PostgreSQL container"
        echo "  restart  - Restart PostgreSQL container"
        echo "  logs     - Show container logs"
        echo "  connect  - Connect to database with psql"
        echo "  status   - Show container and database status"
        echo "  clean    - Remove container and all data (⚠️  destructive)"
        echo ""
        exit 1
        ;;
esac