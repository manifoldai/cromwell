# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Cromwell is an open-source Workflow Management System for bioinformatics that executes WDL (Workflow Description Language) workflows across various computational backends. It's built on Scala with an actor-based architecture using Akka for scalability and fault tolerance.

## Build and Development Commands

### Building the Project
- `sbt assembly` - Build the main Cromwell JAR (creates `server/target/scala-2.13/cromwell-*.jar`)
- `sbt compile` - Compile all source code without creating JARs
- `sbt clean` - Clean build artifacts
- `sbt server/docker` - Build Docker image for local development

### Testing
- `sbt test` - Run unit tests with default exclusions
- `sbt "testOnly *TestClassName*"` - Run specific test classes
- `sbt "centaur / IntegrationTest / test"` - Run integration tests
- `./src/ci/bin/testCentaurLocal.sh` - Run local backend integration tests

### Code Quality
- `sbt scalafmtAll` - Format all Scala code (required before commits)
- `sbt scalafmtCheckAll` - Check code formatting (used in CI)
- `sbt coverage test` - Run tests with coverage report

## Architecture Overview

### Core Modules
- **WOM (Workflow Object Model)**: Core workflow representation in `wom/`
- **WDL Language Factories**: Version-specific parsers in `languageFactories/`
  - Draft-2, Draft-3 (1.0), Biscayne (1.1), Cascades (2.0)
- **Engine**: Main workflow execution logic in `engine/`
- **Backend**: Pluggable execution environments in `supportedBackends/`
- **Services**: Shared services (metadata, caching, instrumentation) in `services/`
- **Core**: Fundamental data types and utilities in `core/`

### Key Architectural Patterns
- **Actor-Based Concurrency**: Built on Akka actors for scalability
- **Plugin Architecture**: Modular backends and filesystems
- **Service Registry**: Centralized service discovery and lifecycle management
- **Language Factory Pattern**: Multi-version WDL support

### Execution Flow
```
WDL Source → Language Factory → WOM → Execution Graph → Backend Execution
```

### Supported Backends
- **Cloud**: AWS Batch, Google Cloud Batch, Google Pipelines API
- **HPC**: SLURM, LSF, SGE, HTCondor
- **Local**: Direct execution, Docker, Singularity
- **Standards**: TES (Task Execution Service)

## Development Patterns

### Database Integration
- Uses Slick for database access with MySQL/PostgreSQL support
- Batch operations for performance
- Call caching system for workflow optimization
- Metadata archival for long-term storage

### Configuration
- Typesafe Config with reference.conf → application.conf → user config hierarchy
- Environment-specific configurations in `src/ci/resources/`
- Backend-specific configuration blocks

### Testing Strategy
- Unit tests for individual components
- Integration tests via Centaur test framework
- Test cases in `centaur/src/main/resources/standardTestCases/`
- Backend-specific test suites

### File I/O Patterns
- Pluggable filesystem support (GCS, S3, HTTP, FTP, DRS)
- AsyncIo for non-blocking operations
- Batch file operations for efficiency
- Cloud-native file handling with proper authentication

## Key Services and Components

### Workflow Execution
- **WorkflowManagerActor**: Manages workflow lifecycle
- **WorkflowExecutionActor**: Orchestrates execution graph traversal
- **EngineJobExecutionActor**: Coordinates individual task execution
- **JobTokenDispenserActor**: Controls concurrent job execution

### Metadata Management
- Hierarchical metadata structure (Workflow → Job → Task)
- RESTful API for metadata queries
- Configurable metadata archival strategies

### Call Caching
- Deterministic hashing: Input + Docker + Command = Cache Key
- Copy strategies for efficient result reuse
- Automatic cache invalidation

## Common Development Tasks

### Adding New Backend Support
1. Implement `BackendLifecycleActorFactory` and related actors
2. Add backend-specific configuration schema
3. Create filesystem integration if needed
4. Add test cases in Centaur

### WDL Language Extensions
1. Extend appropriate language factory (draft3, biscayne, cascades)
2. Update WOM transformations
3. Add test cases covering new features

### API Endpoints
- RESTful endpoints in `server/src/main/scala/cromwell/webservice/`
- WES (Workflow Execution Service) compliance
- Swagger/OpenAPI documentation

## Testing and CI

### Local Testing
- Use `./scripts/local-docker-database/start_mysql_docker.sh` for database testing
- Integration tests require Docker for container execution
- Use `./centaur/test_cromwell.sh` for comprehensive testing

### CI Pipeline
- GitHub Actions with multiple test matrices
- Separate workflows for different backends and databases
- Formatting checks with ScalaFmt
- Coverage reporting with CodeCov

## Dependencies and Prerequisites
- Java 11+
- Scala 2.13
- SBT 1.8.2
- Docker (for container backends and integration tests)
- MySQL/PostgreSQL (for database testing)