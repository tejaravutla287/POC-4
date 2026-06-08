FROM tomcat:9.0-jdk11-openjdk-slim

# Remove default Tomcat apps to keep the environment secure and clean
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the built artifact into Tomcat's root execution path
COPY target/color-app.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
