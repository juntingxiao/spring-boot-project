pipeline {
    environment{
        COMMIT_ID = ""
        ACR_NAME  = "acrfordemoapp"
        IMAGE_NAME = "spring-boot-project"
        NAMESPACE = "kubernetes"
        ACR_ADDRESS = "acrfordemoapp.azurecr.io"
        REGISTRY_DIR = "app"     
        DEPLOY_FILE = "deploy/demo-deploy.yaml"
        AKS_CONFIG = "aksapp-st"        
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
#  - name: yq
#    image: linuxserver/yq:3.2.2
#    command: ["sleep", "3600"]  # 示例命令，这里使用 sleep 命令来保持容器运行
#    tty: true    
  - name: kube-cli
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
                // container('yq') {
                //     sh """
                //     yq -yi '.spec.template.spec.containers[0].image = "${ACR_ADDRESS}/${REGISTRY_DIR}/${IMAGE_NAME}:${TAG}"' ${DEPLOY_FILE}
                //     """                    
                // }
                // withCredentials([file(credentialsId: "${AKS_CONFIG}", variable: 'kubeconfig')]) {
                //     container('kubectl') {
                //         sh """
                //         echo \$kubeconfig > kubectt
                //         kubectl --kubeconfig \$kubeconfig apply -f deploy/
                //         """                        
                //     }
                //withCredentials([string(credentialsId: "${AKS_CONFIG}", variable: 'SECRET')]) { //set SECRET with the credential content
                //    echo "My secret text is '${SECRET}'"
                    container('kube-cli') {
                        sh """
                        ls -l
                        kubectl version
                        """                        
                    }        
                               

                //}                    
            }
        }
        }

    }
}


