pipeline {
    agent any

    environment {
        SONARQUBE_URL = 'http://sonarqube:9000'
        GIT_URL = 'https://github.com/Aseemkhan1/ci-cd.git'
        GIT_BRANCH = 'main'
        SCANNER_HOME = tool 'SonarQube'
    }

    stages {
        
        stage('WorkSpace_Cleanup') {
            steps {
                cleanWs()
            }
        }
        
        stage('Code Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: "*/${env.GIT_BRANCH}"]],
                    userRemoteConfigs: [[url: env.GIT_URL]]
                ])
            }
        }

        stage('SonarQube Analysis For Code Quality') {
            steps {
                withCredentials([string(credentialsId: '17982201-3b20-4c51-9740-0385e057c712', variable: 'sonartoken')]) {
                    sh """
                        ${SCANNER_HOME}/bin/sonar-scanner \\
                            -Dsonar.host.url=${SONARQUBE_URL} \\
                            -Dsonar.login=${sonartoken} \\
                            -Dsonar.projectKey=pipeline-project \\
                            -Dsonar.projectName='pipeline-project-code-quality' \\
                            -Dsonar.language=java \\
                            -Dsonar.tests=src/test/java \\
                            -Dsonar.projectVersion=1.0 \\
                            -Dsonar.sources=src/main/java
                    """
                }
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                dependencyCheck additionalArguments: '--format HTML', odcInstallation: 'OWASP'
            }
        }

        stage('SAST') {
            steps {
                withCredentials([string(credentialsId: '17982201-3b20-4c51-9740-0385e057c712', variable: 'sonartoken')]) {
                    sh """
                        ${SCANNER_HOME}/bin/sonar-scanner \\
                            -Dsonar.host.url=${SONARQUBE_URL} \\
                            -Dsonar.login=${sonartoken} \\
                            -Dsonar.projectKey='sast-pipeline-project' \\
                            -Dsonar.projectName='sast-pipeline-project' \\
                            -Dsonar.language=java \\
                            -Dsonar.tests=src/test/java \\
                            -Dsonar.projectVersion=1.0 \\
                            -Dsonar.sources=src/main/java \\
                            -Dsonar.issuesReport.console.enable=true \\
                            -Dsonar.profile=sast-profile
                    """
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    dockerImage = 'app:latest'
                    sh "docker build -t ${dockerImage} ."
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                script {
                     sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --severity HIGH,CRITICAL ${dockerImage} > ${WORKSPACE}/Trivy_Report.json"
                }
            }
        }

        stage('Artifact-Upload') {
            steps {
                script {
                    def dockerImage = 'app:latest'
                    def dockerRepo = 'aseemkhan'
                    withCredentials([usernamePassword(credentialsId: 'DockerHubCred', passwordVariable: 'DOCKER_HUB_PASSWORD', usernameVariable: 'DOCKER_HUB_USERNAME')]) {
                        sh """
                            echo ${DOCKER_HUB_PASSWORD} | docker login -u ${DOCKER_HUB_USERNAME} --password-stdin
                            docker tag ${dockerImage} ${dockerRepo}/app:latest
                            docker push ${dockerRepo}/app:latest
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: '**/*,trivy-report.json'
        }
    }
}
