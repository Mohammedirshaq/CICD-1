pipeline {
    agent any
/* tools {
        terraform 'terra'  // This will install Terraform automatically
    } */
    environment {
        SONAR_URL = 'http://35.211.186.41:9000'
        SONAR_TOKEN = credentials('sonar-token')  // Add this in Jenkins credentials
        IMAGE_NAME = "mdirshaq/javasample1"
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
        GOOGLE_APPLICATION_CREDENTIALS = credentials('gcp')
   
    }

    stages {

        stage('Build with Maven') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {  // This automatically sets SONAR_URL and SONAR_TOKEN
                sh '''
                mvn sonar:sonar \
                    -Dsonar.projectKey=my-project \
                    -Dsonar.token=${SONAR_TOKEN}
                '''
               }
            }
        }
       




  
        stage('Build Docker Image') {
    steps {
        sh '''
        docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
        docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:${BUILD_NUMBER}
        docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest
        docker images

        '''
    }
}
        stage('Docker Login & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh '''
                    echo $PASSWORD | docker login -u $USERNAME --password-stdin
                    docker push ${IMAGE_NAME}:${BUILD_NUMBER} || echo "Push Failed, Retrying..."
                    docker push ${IMAGE_NAME}:latest
                    '''
                }
            }
        }



        stage('Terraform Workspace Setup') {
    steps {
        sh '''
        terraform init 
        terraform plan
        terraform apply -auto-approve
        '''
    }
}

        //  stage('Terraform Apply') {
        //     steps {
           
        //          sh 'terraform init '
        //          sh 'terraform plan'
        //         sh 'terraform apply -auto-approve'
        
        //        // sh 'terraform destroy -auto-approve' //
        //     }
        // }
          
        
        stage("Check Connection") {
            steps {
                sh '''
                ansible-inventory --graph
                '''
            }
        }

        stage("Ping Ansible") {
            steps {
                sh '''
                sleep 20
                ansible all -m ping
                '''
            }
        }
        stage('Ansible Deployment') {
            steps {
                sh '''
                ansible-playbook ansible.yml -e build_number=$BUILD_NUMBER   
                '''
            }
        }


        

      
    }
        

    post {
        success {
            echo "Application successfully deployed in a Docker container!"
        }
        failure {
            echo "Build failed!"
        }
    }
}
