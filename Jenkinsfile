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
        AKS_CONFIG = "aks-demo"
        DEPLOY_FILE = "deploy/demo-deploy.yaml"
    }    
    stages {
        stage('building'){
            steps{
                sh"""
                    ls -l
                    pwd
                    mvn clean install -DskipTests
                """
            }
        }          
        stage('docker build'){
            steps{
                script{
                    TAG = "${BUILD_NUMBER}"
                    sh"""
                        az login --service-principal --username 222be189-63e8-4fec-9c60-de9fde36811e --password CP28Q~Idm.yx0fTuqV1ebGK4xpmpv4SV1ygBCcRz --tenant fafc518b-2d6a-4c21-bb5c-be77fbdd3eab
                        az keyvault secret show --name acr0823 --vault-name kv-demo0823 --query 'value' -o tsv > ACR_PWD
                        cat ACR_PWD  | docker login --username acr0823 --password-stdin ${ACR_ADDRESS}
                        docker build -t ${ACR_ADDRESS}/${REGISTRY_DIR}/${IMAGE_NAME}:${TAG} .
                        docker push ${ACR_ADDRESS}/${REGISTRY_DIR}/${IMAGE_NAME}:${TAG}
                        docker logout ${ACR_ADDRESS}
                    """
                }
            }
        }  
        stage('Deploying to K8s') {
        environment {
            MY_KUBECONFIG = credentials("${AKS_CONFIG}")
        }
        steps {
            script{
                sh """
                yq -i '.spec.template.spec.containers[0].image = "${ACR_ADDRESS}/${REGISTRY_DIR}/${IMAGE_NAME}:${TAG}"' ${DEPLOY_FILE}
                kubectl --kubeconfig $MY_KUBECONFIG apply -f deploy/
                """
            }
        }
        }

    }
    post {
        always {
            cleanWs()
        }
    }
}



