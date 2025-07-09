## First Run
cd aning-prototype

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

## Call Caching Test WDL
```bash
curl -X POST "http://localhost:8000/api/workflows/v1" \
    -H "accept: application/json" \
    -F "workflowSource=@call_caching_demo.wdl" \
    -F "workflowInputs=@call_caching_inputs.json"
```