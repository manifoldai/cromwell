version 1.0

workflow HelloWorld {
  input {
    String name = "World"
  }
  
  call SayHello { input: name = name }
  
  output {
    String message = SayHello.message
  }
}

task SayHello {
  input {
    String name
  }
  
  command <<<
    echo "Hello, ${name}!"
  >>>
  
  output {
    String message = stdout()
  }
  
  runtime {
    docker: "ubuntu:20.04"
    memory: "1 GB"
    cpu: 1
    jobRoleArn: "arn:aws:iam::071867742034:role/stage-usr-aning@manifold.ai"
  }
}