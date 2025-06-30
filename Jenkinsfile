
Map gitRepo = [
    url: 'https://github.com/ak1ra-lab/selfhosted-server.git'
]
String playbook_hosts = 'localhost'

pipeline {
    agent any

    environment {
        TZ = 'Asia/Shanghai'
    }

    // once every two hours between 08:00 and 18:00 every weekday
    triggers {
        pollSCM('H H(8-18)/2 * * 1-5')
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    parameters {
        gitParameter(
            name: 'branch',
            type: 'PT_BRANCH',
            branchFilter: 'origin/(.*)',
            defaultValue: 'master',
            description: 'Git branch to build'
        )
        string(
            name: 'playbook_hosts',
            defaultValue: playbook_hosts,
            description: 'Ansible Inventory hosts'
        )
    }

    stages {
        stage('checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: params.branch]],
                    userRemoteConfigs: [gitRepo],
                    extensions: [cloneOption(shallow: true, noTags: true)],
                ])
            }
        }

        stage('deploy with playbook') {
            steps {
                ansiColor('xterm') {
                    ansiblePlaybook(
                        installation: 'ansible',
                        playbook: 'install.yml',
                        colorized: true,
                        extraVars: [
                            playbook_hosts: params.playbook_hosts
                        ]
                    )
                }
            }
        }
    }
}
