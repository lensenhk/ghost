FROM b3log/solo:v3.6.1
WORKDIR /opt/solo/
EXPOSE 8080
ENTRYPOINT [ "java", "-cp", "WEB-INF/lib/*:WEB-INF/classes", "org.b3log.solo.Starter" ]