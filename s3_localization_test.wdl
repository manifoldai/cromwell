version 1.0

workflow S3LocalizationTest {
  input {
    # S3 input file that will be localized (downloaded) to the container
    File input_file = "s3://al-test-cloudfront-logs/test-input.txt"
    String output_prefix = "processed"
  }
  
  call ProcessFile { 
    input: 
      input_file = input_file,
      output_prefix = output_prefix
  }
  
  output {
    # This will be delocalized (uploaded) back to S3
    File processed_file = ProcessFile.output_file
    String file_contents = ProcessFile.contents
  }
}

task ProcessFile {
  input {
    File input_file
    String output_prefix
  }
  
  command <<<
    echo "Processing file: ~{input_file}"
    echo "File location in container: ~{input_file}"
    echo "Working directory: $(pwd)"
    echo "Files in current directory:"
    ls -la
    
    # Show that the file was localized (downloaded)
    echo "=== Input file contents ==="
    cat "~{input_file}"
    
    # Process the file (simple transformation)
    echo "=== Processing ==="
    echo "Processed on $(date)" > "~{output_prefix}_output.txt"
    echo "Original content:" >> "~{output_prefix}_output.txt"
    cat "~{input_file}" >> "~{output_prefix}_output.txt"
    echo "Processing complete!" >> "~{output_prefix}_output.txt"
    
    # Show the output file was created locally
    echo "=== Output file created ==="
    cat "~{output_prefix}_output.txt"
    echo "Output files created:"
    ls -la *.txt
  >>>
  
  output {
    File output_file = "${output_prefix}_output.txt"
    String contents = read_string("${output_prefix}_output.txt")
  }
  
  runtime {
    docker: "ubuntu:20.04"
    memory: "1 GB"
    cpu: 1
#    jobRoleArn: "arn:aws:iam::071867742034:role/stage-usr-aning@manifold.ai"
  }
}