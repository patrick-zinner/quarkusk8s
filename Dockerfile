FROM oracle/graalvm-ce:1.0.0-rc15
COPY target/lib/* /deployments/lib/
COPY target/quarkusk8s-runner.jar /deployments/app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","-Dquarkus.http.host=0.0.0.0", "/deployments/app.jar"]
