## First Run
cd aning-prototype

## Hello World WDL
```bash
curl -X POST "http://localhost:8000/api/workflows/v1" \
    -H "accept: application/json" \
    -F "workflowSource=@hello_world.wdl" \
    -F "workflowInputs={}"
```

## Hello World with custom role and no caching
```bash
curl -X POST "http://localhost:8000/api/workflows/v1" \
  -H "accept: application/json" \
  -F "workflowSource=@hello_world.wdl" \
  -F "workflowInputs={}" \
  -F 'workflowOptions={"aws_batch_job_role_arn": "arn:aws:iam::071867742034:role/stage-usr-aning@manifold.ai", "write_to_cache": 
  false, "read_from_cache": false}'
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