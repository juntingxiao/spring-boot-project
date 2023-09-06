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
        SONAR_TOKEN = "squ_b29e2582baccd69178fcd7124819ac4b3dc7de62"
        SONAR_URL = "http://sonarqube-sonarqube.sonarqube.svc.cluster.local:9000"
    }    
   
    //agent any
    agent{
        kubernetes {
          cloud 'ns-agent' // 在jenkins中可以配置多个集群， 在这里指定集群名称
          yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - command:
      - "cat"
    env:
      - name: "LANGUAGE"
        value: "en_US:en"
      - name: "LC_ALL"
        value: "en_US.UTF-8"
      - name: "LANG"
        value: "en_US.UTF-8"
    image: "registry.cn-beijing.aliyuncs.com/citools/docker:19.03.9-git"
    #image: '10.211.55.107/kubernetes/docker:19.03.9-git'    
    imagePullPolicy: "IfNotPresent"
    name: "docker"
    tty: true
    volumeMounts:
    - mountPath: "/var/run/docker.sock"
      name: "dockersock"
      readOnly: false
  - name: maven
    image: maven:3.6.3-jdk-11-slim
    command: ["sleep", "3600"]  # 示例命令，这里使用 sleep 命令来保持容器运行
    tty: true
    volumeMounts:
    - mountPath: "/root/.m2/"
      name: "cachedir"
      readOnly: false    
  - name: yq
    image: linuxserver/yq:3.2.2
    command: ["sleep", "3600"]  # 示例命令，这里使用 sleep 命令来保持容器运行
    tty: true    
  - name: kube-cli
    image: alpine:latest
    command: ["sleep", "3600"]  # 示例命令，这里使用 sleep 命令来保持容器运行
    tty: true   
  volumes:
    - hostPath:
        path: "/var/run/docker.sock"
      name: "dockersock"      
    - name: "cachedir"
      persistentVolumeClaim:
        claimName: maven-pvc
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
                      -Dsonar.host.url=${SONAR_URL} \
                      -Dsonar.token=${SONAR_TOKEN} \
                      -Dmaven.repo.remote=https://maven.aliyun.com/repository/public
                    """
                }
            }
      }
        stage('building'){
            steps{
                container(name: 'maven'){
                    sh"""
                      # mvn clean install -DskipTests
                      mvn clean install -DskipTests -Dmaven.repo.remote=https://maven.aliyun.com/repository/public
                    """
                }
            }
        }       
        stage('Docker build for create image') {
            steps {
                script {
                    // withCredentials([azureServicePrincipal('azure-sp-sit')]){
                        TAG = "${BUILD_NUMBER}"
                        container('docker') {
                            sh """
                                docker build -t ${REGISTRY_DIR}/${IMAGE_NAME}:${TAG} .
                                docker save -o ${REGISTRY_DIR}_${IMAGE_NAME}_${TAG}.image ${REGISTRY_DIR}/${IMAGE_NAME}:${TAG}                
                            """
                        } 
                    // }
                    archiveArtifacts artifacts: "${REGISTRY_DIR}_${IMAGE_NAME}_${TAG}.image" , fingerprint: false
                }               
            }
        }  
        // stage('Deploying to AKS') {
        //     steps {
        //         script{
        //             container('yq') {
        //                 sh """
        //                 yq -yi '.spec.template.spec.containers[0].image = "${ACR_ADDRESS}/${REGISTRY_DIR}/${IMAGE_NAME}:${TAG}"' ${DEPLOY_FILE}
        //                 """                    
        //             }
        //             withCredentials([file(credentialsId: "${AKS_CONFIG}", variable: 'kubeconfig')]) { //set SECRET with the credential content
        //                 container('kube-cli') {
        //                     sh"""
        //                     apk add --update curl && rm -rf /var/cache/apk/*
        //                     curl -LO "https://storage.googleapis.com/kubernetes-release/release/\$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
        //                     chmod +x kubectl
        //                     ./kubectl version
        //                     ./kubectl --kubeconfig=\$kubeconfig apply -f deploy/
        //                     """                         
        //                 }        
                                

        //             }                    
        //         }
        //     }
        // }
    }
}
