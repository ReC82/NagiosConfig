pipeline {
    agent {
        label "main"
    }

    environment {
        // SERVER CONFIG
        NAGIOS_SERVER = "10.1.6.4"
        NAGIOS_CREDENTIALS = 'Nagios'
        REMOTE_PATH = '/usr/local/nagios/etc/servers/'
        // EMAIL CONFIG
        RECIPIENTS = 'lody.devops@gmail.com'
        SENDER_EMAIL = 'jenkins@lodywood.be'
        // GIT CONFIG
        ARTIFACT_REPO = 'git@github.com:ReC82/NagiosConfig.git'
        GIT_CREDENTIALS = 'GitJenkins'
        TARGET_BRANCH = 'main'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Deploy new config files on Nagios') {
            steps {
                script {
                    withCredentials([sshUserPrivateKey(
                        credentialsId: env.NAGIOS_CREDENTIALS,
                        keyFileVariable: 'SSH_KEY_FILE',                        
                        usernameVariable: 'SSH_USER'
                    )]) {
                        sh 'ssh-keyscan \$NAGIOS_SERVER >> ~/.ssh/known_hosts'
                        sh 'pwd'

                        sh """
                        scp -o StrictHostKeyChecking=no -i \$SSH_KEY_FILE ${WORKSPACE}/servers/*.cfg \${SSH_USER}@\${NAGIOS_SERVER}:\${REMOTE_PATH}
                        """

                        sh """
                        ssh -o StrictHostKeyChecking=no -i \$SSH_KEY_FILE \${SSH_USER}@\${NAGIOS_SERVER} \\
                            "sudo systemctl restart nagios"
                        """
                    }
                }
            }
        }          
    }
    post {
        failure {
            emailext(
                subject: "Nagios Update Config Failed",
                body: """
Build Result: ${currentBuild.result}
Build Number: ${currentBuild.number}
Build URL: ${env.BUILD_URL}
You can download the build report [here](${env.BUILD_URL}artifact/build-report.txt).
""",
                to: env.RECIPIENTS,
                from: env.SENDER_EMAIL,
                attachLog: true
            )
        }
    }
}