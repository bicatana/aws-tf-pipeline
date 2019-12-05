#!groovy

podTemplate(cloud: "kubernetes", containers: [
    containerTemplate(name: 'jnlp', image: 'jenkinsci/jnlp-slave:alpine', ttyEnabled: true, alwaysPullImage: true),
    containerTemplate(name: 'terraform', image: 'hashicorp/terraform:latest', ttyEnabled: true, command: 'cat', alwaysPullImage: true),
    containerTemplate(name: 'kaniko', image: 'gcr.io/kaniko-project/executor:debug', ttyEnabled: true, command: '/busybox/cat', alwaysPullImage: true)
]) {
    node(POD_LABEL) {
        //Vault Configuration
        def configuration = [vaultUrl: 'http://10.100.36.190:8200',
                            vaultCredentialId: 'vault-token', engineVersion: 1]
        //Define Required Secrets and Env Variables
        def secrets = [
            [path: 'kv/docker', secretValues: [
                [envVar: 'DOCKER_CONFIG_FILE', vaultKey: 'config']]],
            [path: 'kv/aws', secretValues: [
                [envVar: 'AWS_CREDENTIALS_FILE', vaultKey: 'credentials']]]
        ]
        //Use the Credentials with the Build
        withVault([configuration: configuration, vaultSecrets: secrets]) {
            //Checkout code from GitHub
            stage ('Checkout') {
                try {
                    git credentialsId: 'github-key', branch: "$BRANCH_NAME", url: "git@github.com:bicatana/aws-tf-pipeline.git"
                }
                catch (exc) {
                    println "Failed the Git Checkout - ${currentBuild.fullDisplayName}"
                }
            }
            //Ensure that Terraform works properly
            stage('Check Workspace & Setup connection to Stash') {
                container('terraform'){
                    try {
                        sh "terraform -v"
                    }
                    catch (exc) {
                        println "Failed the Workspace Check & Stash Setup - ${currentBuild.fullDisplayName}"
                        throw(exc)
                    }
                }
            }
            //Setup the AWS credentials
            stage('Set AWS Credentials') {
                container('terraform'){
                    try {
                        sh """
                            set +x
                            mkdir ~/.aws
                            echo '$AWS_CREDENTIALS_FILE' > ~/.aws/credentials
                        """
                    }
                    catch (exc) {
                        println "Failed the Azure Steps - ${currentBuild.fullDisplayName}"
                        throw(exc)
                    }
                }
            }
            //Run Terraform Plan Stage
            stage('Terraform - Init, Validate & Plan') {
                container('terraform') {
                    try {
                        //change directory from the beginning as it defaults to the checkout folder in the workspace
                        //Do init, validate and plan before packaging up the stuff!!!
                        sh """
                            cd src/
                            pwd
                            terraform init
                            terraform validate
                            terraform plan -out=terraform.plan
                        """

                    }
                    catch (exc) {
                        println "Terraform Steps Failed - ${currentBuild.fullDisplayName}"
                        throw(exc)
                    }
                }
            }
            //Package up and ship via Kaniko
            stage('Kaniko - Build & Ship') {
                container('kaniko') {
                    try {
                        //Kaniko Build and Ship to Docker Hub
                        //Use --verbosity=debug for more detailed logs if necessary
                        env.DOCKER_CONFIG = "/kaniko/.docker"
                        sh """
                        set +x
                        echo '$DOCKER_CONFIG_FILE' > config.json
                        cp config.json /kaniko/.docker/config.json
                        /kaniko/executor --dockerfile=$WORKSPACE/Dockerfile --context=$WORKSPACE  --destination=bicatana/k8s:terraform --skip-tls-verify
                        """                  
                    }
                    catch (exc) {
                        println "Kaniko Steps Failed - ${currentBuild.fullDisplayName}"
                        throw(exc)
                    }
                }
            }
        }
    }
}