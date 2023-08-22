pipeline {
    agent {
        label 'local-agent'
    }
    environment{
        COMMIT_ID = ""
        ACR_ADDRESS = "acr0823.azurecr.io"
        REGISTRY_DIR = "general"
        IMAGE_NAME = "spring-boot-project"
        NAMESPACE = "kubernetes"
    }    
    stages {
        stage('building'){
            steps{
                sh"""
                    mvn clean install -DskipTests
                """
            }
        }          
        stage('docker build'){
            steps{
                TAG = "${BUILD_NUMBER}"
                sh"""
                    az login --service-principal --username 222be189-63e8-4fec-9c60-de9fde36811e --password CP28Q~Idm.yx0fTuqV1ebGK4xpmpv4SV1ygBCcRz --tenant fafc518b-2d6a-4c21-bb5c-be77fbdd3eab
                    az keyvault secret show --name kv-demo0823 --vault-name acr0823 --query 'value' -o tsv > ACR_PWD
                    cat ACR_PWD  | docker login --username acr0823 --password-stdin ${ACR_ADDRESS}
                    docker build -t ${ACR_ADDRESS}/${REGISTRY_DIR}/${IMAGE_NAME}:${TAG} .
                    docker push ${ACR_ADDRESS}/${REGISTRY_DIR}/${IMAGE_NAME}:${TAG}
                """
            }
        }               
        // stage('Hello') {
        //     steps {
        //         echo 'Hello World'
        //         sh """
        //         docker ps 
        //         echo \$(date) >> 123.log
        //         cat 123.log
        //         ls -l
        //         pwd
        //         """
        //         sh"""
        //             az login --service-principal --username 222be189-63e8-4fec-9c60-de9fde36811e --password CP28Q~Idm.yx0fTuqV1ebGK4xpmpv4SV1ygBCcRz --tenant fafc518b-2d6a-4c21-bb5c-be77fbdd3eab
        //             az keyvault secret show --name kv-demo0823 --vault-name acr0823 --query 'value' -o tsv
        //         """                
        //     }
        // }
    }
}

echo "your_password" | docker login --username your_username --password-stdin your_registry_url
