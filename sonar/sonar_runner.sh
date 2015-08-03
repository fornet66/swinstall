
export SONAR_RUNNER_OPTS="-Xmx512m -XX:MaxPermSize=512m"
sonar-runner -Dsonar.analysis.mode=preview \
	-Dsonar.projectKey=bms \
	-Dsonar.projectName=bms \
	-Dsonar.projectVersion=1.0 \
	-Dsonar.projectBaseDir=/home/xienan/work/cvs/products/ibs \
	-Dsonar.sources=. \
	-Dsonar.working.directory=/home/xienan/temp/sonar_runner_work
java -Ddepartment=010 -Dauthor=xienan -Dproject=bms -Dversion=2.0 -jar AnalysisReportplugin-1.0.jar

sonar-runner -Dsonar.analysis.mode=preview \
	-Dsonar.projectKey=skymanage \
	-Dsonar.projectName=skymanage \
	-Dsonar.projectVersion=1.0 \
	-Dsonar.projectBaseDir=/home/xienan/work/cvs/products \
	-Dsonar.sources=skymanage \
	-Dsonar.working.directory=/home/xienan/temp/sonar_runner_work
java -Ddepartment=010 -Dauthor=xienan -Dproject=skymanage -Dversion=2.0 -jar AnalysisReportplugin-1.0.jar

sonar-runner -Dsonar.analysis.mode=preview \
	-Dsonar.projectKey=np \
	-Dsonar.projectName=np \
	-Dsonar.projectVersion=3.0 \
	-Dsonar.projectBaseDir=/home/xienan/work/cvs/products \
	-Dsonar.sources=np \
	-Dsonar.working.directory=/home/xienan/temp/sonar_runner_work
java -Ddepartment=010 -Dauthor=xienan -Dproject=np -Dversion=2.0 -jar AnalysisReportplugin-1.0.jar

java -Ddepartment=010 -Ddate=20150802 -jar SonarStat-1.0.jar


