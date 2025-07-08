## Hello World WDL
```bash
curl -X POST "http://localhost:8000/api/workflows/v1" \
    -H "accept: application/json" \
    -F "workflowSource=@hello_world.wdl" \
    -F "workflowInputs={}"
```

## Localization Test WDL
```bash
curl -X POST "http://localhost:8000/api/workflows/v1" \
    -H "accept: application/json" \
    -F "workflowSource=@s3_localization_test.wdl" \
    -F "workflowInputs=@test_inputs.json"
```