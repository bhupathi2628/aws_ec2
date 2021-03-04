pipeline{

    environment { 
        AWS_ACCESS_KEY_ID = credentials('Aws_Access_Key_Id')
        AWS_SECRET_ACCESS_KEY = credentials('Aws_Secret_Access_Key')
    }
    agent any

    stages{
        stage('git Checkout'){
            steps{
                git 'https://github.com/bhupathi2628/aws_ec2.git'
            }
        }
        stage('terrafrom init'){
            steps{
                sh 'terraform init' 
            }
        }
        stage('terrafrom paln'){
            steps{
                sh 'terraform plan'
            }
        }
        stage('terrafrom apply'){
            steps{
                sh 'terraform apply --auto-approve'
            }
        }
    }
}


