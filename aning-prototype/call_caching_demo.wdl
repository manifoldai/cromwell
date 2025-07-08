version 1.0

workflow CallCachingDemo {
    input {
        String input_message = "Hello from call caching!"
        Int sleep_duration = 30
        String output_prefix = "demo"
    }
    
    # Task 1: CPU-intensive task that takes time
    call ExpensiveComputation {
        input: 
            message = input_message,
            duration = sleep_duration
    }
    
    # Task 2: File processing task
    call ProcessFile {
        input:
            input_text = ExpensiveComputation.result,
            prefix = output_prefix
    }
    
    # Task 3: Another computation with different inputs
    call AnotherComputation {
        input:
            base_message = input_message,
            multiplier = 3
    }
    
    output {
        String final_result = ProcessFile.output_file
        String computation_result = AnotherComputation.repeated_message
        String original_result = ExpensiveComputation.result
    }
}

task ExpensiveComputation {
    input {
        String message
        Int duration
    }
    
    command <<<
        echo "Starting expensive computation at $(date)"
        echo "Processing: ~{message}"
        
        # Simulate CPU-intensive work
        echo "Computing for ~{duration} seconds..."
        sleep ~{duration}
        
        # Generate some output
        echo "Computation completed at $(date)"
        echo "Result: ~{message} - processed with intensive computation" > result.txt
        
        # Show some system info to make the output unique per run
        echo "Hostname: $(hostname)" >> result.txt
        echo "Current time: $(date)" >> result.txt
        echo "Process ID: $$" >> result.txt
    >>>
    
    output {
        String result = read_string("result.txt")
    }
    
    runtime {
        docker: "ubuntu:20.04"
        memory: "1 GB"
        cpu: 1
    }
}

task ProcessFile {
    input {
        String input_text
        String prefix
    }
    
    command <<<
        echo "Processing file at $(date)"
        echo "Input text: ~{input_text}" > input.txt
        
        # Simulate file processing
        echo "File processing started..." 
        sleep 10
        
        # Transform the input
        echo "=== PROCESSED FILE ===" > ~{prefix}_output.txt
        echo "~{input_text}" >> ~{prefix}_output.txt
        echo "Processed at: $(date)" >> ~{prefix}_output.txt
        echo "Processing completed!" >> ~{prefix}_output.txt
    >>>
    
    output {
        File output_file = "${prefix}_output.txt"
    }
    
    runtime {
        docker: "ubuntu:20.04"
        memory: "512 MB"
        cpu: 1
    }
}

task AnotherComputation {
    input {
        String base_message
        Int multiplier
    }
    
    command <<<
        echo "Another computation started at $(date)"
        
        # Repeat the message
        result=""
        for i in $(seq 1 ~{multiplier}); do
            result="$result~{base_message} "
        done
        
        echo "Final result: $result" > computation_output.txt
        echo "Computation finished at $(date)" >> computation_output.txt
        
        # Add some delay to make caching more obvious
        sleep 15
    >>>
    
    output {
        String repeated_message = read_string("computation_output.txt")
    }
    
    runtime {
        docker: "ubuntu:20.04"
        memory: "512 MB"
        cpu: 1
    }
}