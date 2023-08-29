FROM registry.cn-beijing.aliyuncs.com/dotbalo/jre:8u211-data
COPY target/spring-cloud-eureka-0.0.1-SNAPSHOT.jar ./
CMD ["java","-jar","spring-cloud-eureka-0.0.1-SNAPSHOT.jar"]


