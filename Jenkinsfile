pipeline {
    agent { label 'SRV-DOCKER-DEV' }
    stages {

        stage('Init'){
            agent { label 'SRV-DOCKER-DEV' }
            steps {
                script {
                    properties([pipelineTriggers([cron('@daily'), [$class: 'PeriodicFolderTrigger', interval: '1d']]), [$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '10']]])
                }
                deleteDir()
            }
        }

        stage('Checkout'){
            steps {
                // GIT submodule recursive checkout
                checkout scm: [
                        $class: 'GitSCM',
                        branches: scm.branches,
                        doGenerateSubmoduleConfigurations: false,
                        extensions: [[$class: 'SubmoduleOption',
                                      disableSubmodules: false,
                                      parentCredentials: false,
                                      recursiveSubmodules: true,
                                      reference: '',
                                      trackingSubmodules: false]],
                        submoduleCfg: [],
                        userRemoteConfigs: scm.userRemoteConfigs
                ]
            }
        }

        stage('Docker build') {
            steps {
                echo 'Starting to build docker image'
                script {
                    app = docker.build("thomasilliet/feedbin-refresher:${env.BUILD_ID}")
                }
            }
        }

        stage('Docker push Latest') {
            when { expression { conditionalBuild('Daily') == true } }
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'ca19e01b-db1a-43a3-adc4-46dafe13fea2') {
                        app.push("latest")
                        app.push( getRemoteCommitID() )
                    }
                }
            }
        }

        stage('Docker push Weekly') {
            when { expression { conditionalBuild('Weekly') == true } }
            steps {
                script {
                    commitId = sh(returnStdout: true, script: 'cd app ; git rev-parse HEAD')
                    docker.withRegistry('https://registry.hub.docker.com', 'ca19e01b-db1a-43a3-adc4-46dafe13fea2') {
                        app.push("weekly")
                    }
                }
            }
        }

        stage('Docker push Monthly') {
            when { expression { conditionalBuild('Monthly') == true } }
            steps {
                script {
                    commitId = sh(returnStdout: true, script: 'cd app ; git rev-parse HEAD')
                    docker.withRegistry('https://registry.hub.docker.com', 'ca19e01b-db1a-43a3-adc4-46dafe13fea2') {
                        app.push("monthly")
                    }
                }
            }
        }

        stage('Update CommitID') {
            when { expression { conditionalBuild('Daily') == true } }
            environment {
                remoteCommitID = getRemoteCommitID()
            }
            steps {
                withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'd6aed6d5-8b11-483b-8651-fedada6e1a64', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
                    sh 'echo $remoteCommitID > CurrentCommitID'
                    sh 'git add CurrentCommitID'
                    sh 'git config user.email "contact@thomas-illiet.fr"'
                    sh 'git commit -m ":wrench: Update current commit ID to $remoteCommitID"'
                    sh 'git config --global push.default simple'
                    sh 'git push https://$USERNAME:$PASSWORD@github.com/thomas-illiet/feedbin-refresher-docker.git HEAD:master'
                }
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    currentCommitID = getRemoteCommitID()
                    sh("docker rmi -f ruby:2.4")
                    sh("docker rmi -f registry.hub.docker.com/thomasilliet/feedbin-refresher:latest")
                    sh("docker rmi -f registry.hub.docker.com/thomasilliet/feedbin-refresher:monthly")
                    sh("docker rmi -f registry.hub.docker.com/thomasilliet/feedbin-refresher:weekly")
                    sh("docker rmi -f registry.hub.docker.com/thomasilliet/feedbin-refresher:$currentCommitID")
                    sh("docker rmi -f thomasilliet/feedbin-refresher:${env.BUILD_ID}")
                    deleteDir()
                    cleanWs()
                }
            }
        }

    }
}

def conditionalBuild (BuildType) {
    jobCause = getJobCause()
    if ( getRemoteCommitID() != getLocalCommitID() ) {
        switch(BuildType) {
            case "Weekly":
                dayOfWeek = sh(returnStdout: true, script: 'date +%u').trim()
                if( ( jobCause == 'timer' || jobCause == 'pushtomaster' ) && dayOfWeek == '4' ) {
                    return true
                } else {
                    return false
                }
                break
            case "Monthly":
                dayOfMonth = sh(returnStdout: true, script: 'date +%d').trim()
                echo "dayofmonth : ${dayOfMonth}"
                if( ( jobCause == 'timer' || jobCause == 'pushtomaster' ) && dayOfMonth == '18' ) {
                    return true
                } else {
                    return false
                }
                break
            case "Daily":
                if( jobCause == 'timer' || jobCause == 'pushtomaster' ) {
                    return true
                } else {
                    return false
                }
                break
            default:
                echo "Unable to find a valid BuildType"
                return false
        }
    } else {
        return false
    }
}



def getRemoteCommitID() {
    return sh(returnStdout: true, script: 'cd app ; git rev-parse HEAD')
}

def getLocalCommitID() {
    return sh(returnStdout: true, script: 'cat CurrentCommitID')
}

@NonCPS
def getJobCause() {
  def jobCause = ''
  def buildCauses = currentBuild.rawBuild.getCauses()
  for ( buildCause in buildCauses ) {
    if (buildCause != null) {
      def causeProperties = buildCause.getProperties()
      if (causeProperties =~ /Started by user/) {
        jobCause = 'user'
      }
      if (causeProperties =~ /Started by timer/) {
        jobCause = 'timer'
      }
        if (causeProperties =~ /Started by an SCM change/) {
        jobCause = 'scm'
      }
      if (causeProperties =~ /Started by upstream/) {
        jobCause = 'upstream'
      }
      if (causeProperties =~ /Push event to branch master/) {
        jobCause = 'pushtomaster'
      }
      if (causeProperties =~ /Push event to branch unstable/) {
        jobCause = 'pushtounstable'
      } else {
        echo "cause properties: ${causeProperties}"
      }
    } else {
    }
  }
  echo "jobCause: ${jobCause}"
  return jobCause
}
