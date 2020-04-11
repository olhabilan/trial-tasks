pipelineJob ('Run_python_script') {
    def repo = 'https://github.com/beerkeeper/python-ip-script.git'
    description("Pipeline for $repo")
    definition {  
        cpsScm {
            scm {
                git('https://github.com/olhabilan/jenkins-scripts.git')
            }
        }
    }
}