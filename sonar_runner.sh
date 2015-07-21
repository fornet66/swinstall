
export SONAR_RUNNER_OPTS="-Xmx512m -XX:MaxPermSize=512m"
sonar-runner -Dsonar.analysis.mode=incremental \
	-Dsonar.projectKey=upload \
	-Dsonar.projectName=upload \
	-Dsonar.projectVersion=1.0 \
	-Dsonar.projectBaseDir=/home/xienan/work/products/ibs/bms/upload \
	-Dsonar.sources=src \
	-Dsonar.working.directory=/home/xienan/sonar_runner_work \
	-Dsonar.issuesReport.html.enable=true \
	-Dsonar.issuesReport.lightModeOnly \
	-Dsonar.issuesReport.html.location=/home/xienan/sonar_runner_work \
	-Dsonar.issuesReport.html.name=upload.html

