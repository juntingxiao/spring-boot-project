pipeline {
    agent {
        label 'local-agent'
    }
    stages {
        stage('Hello') {
            steps {
                echo 'Hello World'
                sh """
                docker ps 
                echo \$(date) >> 123.log
                cat 123.log
                ls -l
                pwd
                """
                sh"""
                    az login --service-principal --username 222be189-63e8-4fec-9c60-de9fde36811e --password CP28Q~Idm.yx0fTuqV1ebGK4xpmpv4SV1ygBCcRz --tenant fafc518b-2d6a-4c21-bb5c-be77fbdd3eab
                    az keyvault secret show --name acr0823 --vault-name kv-demo0823 --query 'value' -o tsv
                """                
            }
        }
    }
}

