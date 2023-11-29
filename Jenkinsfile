pipeline{
    agent any
    tools{
      jdk 'jdk17'
      nodejs 'node16'  
    }
    environment{
        SCANNER_HOME=tool 'sonar_scanner'
    }
    stages{
        stage('clean work space'){
            steps{
                cleanWs()
            }
        }
        stage('git checkout'){
            steps{
                git branch: 'main', credentialsId: 'github', url: 'https://github.com/mukeshr-29/devops-project-16-2048-game.git'
            }
        }
        stage('sonarqube analysis'){
            steps{
                script{
                    withSonarQubeEnv(credentialsId: 'sonarqube'){
                        sh '''
                           $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=2048_game \
                           -Dsonar.projectKey=2048_game 
                        '''
                    }
                }
            }
        }
        stage('quality gate check'){
            steps{
                script{
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonarqube'
                }
            }
        }
        stage('install node dependencies'){
            steps{
                sh 'npm install'
            }
        }
        stage('owasp file scan'){
            steps{
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('trivy file scan'){
            steps{
                sh 'trivy fs . > trivyfs.txt'
            }
        }
        stage('docker build & push'){
            steps{
                script{
                    withDockerRegistry(credentialsId: 'dockerhub', toolName: 'docker'){
                        sh '''
                            docker build -t 2048_game .
                            docker tag 2048_game mukeshr29/2048_game:latest
                            docker push mukeshr29/2048_game:latest
                        '''
                    }
                }
            }
        }
        stage('trivy img scan'){
            steps{
                sh 'trivy image mukeshr29/2048_game:latest > trivy.txt'
            }
        }
        stage('deploy to container'){
            steps{
                sh 'docker run -d --name 2048_game -p 3000:3000 mukeshr29/2048_game:latest'
            }
        }
        stage('deploy in kubernetes'){
            steps{
                script{
                    withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'k8s', namespace: '', restrictKubeConfigAccess: false, serverUrl: ''){
                        sh 'kubectl apply -f deployment.yaml'
                        sh 'kubectl apply -f service.yaml'
                    }
                }
            }
        }
    }
}