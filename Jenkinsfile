pipeline {
    environment{
        COMMIT_ID = ""
        ACR_NAME  = "acrfordemoapp"
        IMAGE_NAME = "spring-boot-project"
        NAMESPACE = "kubernetes"
        ACR_ADDRESS = "acrfordemoapp.azurecr.io"
        REGISTRY_DIR = "app"     
        DEPLOY_FILE = "deploy/demo-deploy.yaml"
        AKS_CONFIG = "aksapp"        
    }    
   
    //agent any
    agent{
        kubernetes {
          cloud 'nsagent' // 在jenkins中可以配置多个集群， 在这里指定集群名称
          yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: aa
    image: alpine:latest
    command: 
    - cat
    tty: true
  - name: azure-cli
    image: mcr.microsoft.com/azure-cli
    command: ["sleep", "3600"]  # 示例命令，这里使用 sleep 命令来保持容器运行
    tty: true
  - name: maven
    image: maven:3.5.3
    command: ["sleep", "3600"]  # 示例命令，这里使用 sleep 命令来保持容器运行
    tty: true
  - name: yq
    image: linuxserver/yq:3.2.2   
    command: ["sleep", "3600"]  # 示例命令，这里使用 sleep 命令来保持容器运行
    tty: true    
  - name: kubectl
    image: bitnami/kubectl:1.27.5
    command: ["sleep", "3600"]  # 示例命令，这里使用 sleep 命令来保持容器运行
    tty: true     
'''
        }
    } 
    stages {
        stage('building'){
            steps{
                container(name: 'maven'){
                    sh"""
                      mvn clean install -DskipTests
                    """
                }
            }
        }       
        stage('Docker build for create image') {
            steps {
                script {
                    TAG = "${BUILD_NUMBER}"
                    container('azure-cli') {
                        sh """
                            az version
                            az login --service-principal --username 397f837c-725e-4dc4-901f-bc1de9bfd366 --password XZI8Q~HWbWdkR~tgOlkl9yuqm3vVx-kH9mmeHb5C --tenant fafc518b-2d6a-4c21-bb5c-be77fbdd3eab
                            az acr build --image ${REGISTRY_DIR}/${IMAGE_NAME}:${TAG} \
                            --registry ${ACR_NAME} \
                            --file Dockerfile .                        
                        """
                    } 
                }               
            }
        }  
        stage('Deploying to AKS') {
        environment {
            MY_KUBECONFIG = credentials("${AKS_CONFIG}")
        }
        steps {
            script{
                container('yq') {
                    sh """
                    yq -i '.spec.template.spec.containers[0].image = "${ACR_ADDRESS}/${REGISTRY_DIR}/${IMAGE_NAME}:${TAG}"' ${DEPLOY_FILE}
                    """                    
                }
                container('kubectl') {
                    sh """
                        kubectl --kubeconfig $MY_KUBECONFIG apply -f deploy/
                    """                    
                }                        
            }
        }
        }

    }
}

