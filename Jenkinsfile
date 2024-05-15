pipeline {
    agent {
        label "main"
    }

    environment {
        // SERVER CONFIG
        NAGIOS_SERVER = "10.1.6.4"
        NAGIOS_CREDENTIALS = 'monitoring.pem'
        REMOTE_PATH = '/usr/local/nagios/etc/servers'
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

                        def copyLogFile = "${WORKSPACE}/copy.log"

                        sh 'ssh-keyscan \$NAGIOS_SERVER >> ~/.ssh/known_hosts'
                        sh 'pwd'

                        sh """
                        ssh -o StrictHostKeyChecking=no -i \$SSH_KEY_FILE \${SSH_USER}@\${NAGIOS_SERVER} \\
                            "rm -rf \${REMOTE_PATH}/*.cfg" > ${copyLogFile} 2>&1
                        """                        

                        sh """
                        scp -o StrictHostKeyChecking=no -i \$SSH_KEY_FILE ${WORKSPACE}/servers/*.cfg \${SSH_USER}@\${NAGIOS_SERVER}:\${REMOTE_PATH} > ${copyLogFile} 2>&1
                        """

                        sh """
                        ssh -o StrictHostKeyChecking=no -i \$SSH_KEY_FILE \${SSH_USER}@\${NAGIOS_SERVER} \\
                            "sudo systemctl restart nagios" > ${copyLogFile} 2>&1
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
