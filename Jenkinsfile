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
  - name: azure-cli
    image: mcr.microsoft.com/azure-cli
    command: ["sleep", "3600"]  # 示例命令，这里使用 sleep 命令来保持容器运行
    tty: true
  - name: maven
    image: maven:3.9.4-amazoncorretto-20-al2023
    command: ["sleep", "3600"]  # 示例命令，这里使用 sleep 命令来保持容器运行
    tty: true
  - name: yq
    image: linuxserver/yq:3.2.2
    command: ["sleep", "3600"]  # 示例命令，这里使用 sleep 命令来保持容器运行
    tty: true    
  - name: kube-cli
    image: alpine:latest
    command: ["sleep", "3600"]  # 示例命令，这里使用 sleep 命令来保持容器运行
    tty: true     

'''
        }
    } 


    stages {
      stage('SonarQube') {
            steps{
                container(name: 'maven'){
                    sh"""
                      mvn clean verify sonar:sonar \
                      -Dsonar.projectKey=spring-boot-project \
                      -Dsonar.projectName='spring-boot-project' \
                      -Dsonar.host.url=http://20.24.234.138:9000 \
                      -Dsonar.token=sqa_bff63df3fd00475696183face63f8091892657c3
                    """
                }
            }
      }
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
                    withCredentials([azureServicePrincipal('azure-sp-sit')]){
                        TAG = "${BUILD_NUMBER}"
                        container('azure-cli') {
                            sh """
                                az version
                                az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID
                                az acr build --image ${REGISTRY_DIR}/${IMAGE_NAME}:${TAG} \
                                --registry ${ACR_NAME} \
                                --file Dockerfile .                        
                            """
                        } 
                    }
                }               
            }
        }  
        stage('Deploying to AKS') {
            steps {
                script{
                    container('yq') {
                        sh """
                        yq -yi '.spec.template.spec.containers[0].image = "${ACR_ADDRESS}/${REGISTRY_DIR}/${IMAGE_NAME}:${TAG}"' ${DEPLOY_FILE}
                        """                    
                    }
                    // withCredentials([file(credentialsId: "${AKS_CONFIG}", variable: 'kubeconfig')]) {
                    //     container('kubectl') {
                    //         sh """
                    //         echo \$kubeconfig > kubectt
                    //         kubectl --kubeconfig \$kubeconfig apply -f deploy/
                    //         """                        
                    //     }
                    withCredentials([file(credentialsId: "${AKS_CONFIG}", variable: 'kubeconfig')]) { //set SECRET with the credential content
                        container('kube-cli') {
                            sh"""
                            apk add --update curl && rm -rf /var/cache/apk/*
                            curl -LO "https://storage.googleapis.com/kubernetes-release/release/\$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
                            chmod +x kubectl
                            ./kubectl version
                            ./kubectl --kubeconfig=\$kubeconfig apply -f deploy/
                            """                         
                        }        
                                

                    }                    
                }
            }
        }
    }
}

