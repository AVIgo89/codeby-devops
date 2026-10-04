pipeline {
    agent none //  [citation:2]

    stages {
        stage('Check Changes and Build in Parallel') {
            parallel {
                
                stage('Hello World!') {
                    
                    when {
                        beforeAgent true
                        changeset "hello-world/**"
                    }
                    agent { label 'maven' } // агент с меткой maven
                    stages {
                        stage('Build') {
                            steps {
                                dir('hello-world') {
                                    sh 'mvn clean package'
                                }
                            }
                        }
                        stage('Test') {
                            steps {
                                dir('hello-world') {
                                    sh 'mvn test'
                                }
                            }
                        }
                        stage('Deploy') {
                            steps {
                                dir('hello-world') {
                                    echo 'Deploying Hello World!...'
                                
                                }
                            }
                        }
                    }
                }

                
                stage('Hello Jenkins!') {
                    when {
                        beforeAgent true
                        changeset "hello-jenkins/**"
                    }
                    agent { label 'maven' }
                    stages {
                        stage('Build') {
                            steps {
                                dir('hello-jenkins') {
                                    sh 'mvn clean package'
                                }
                            }
                        }
                        stage('Test') {
                            steps {
                                dir('hello-jenkins') {
                                    sh 'mvn test'
                                }
                            }
                        }
                        stage('Deploy') {
                            steps {
                                dir('hello-jenkins') {
                                    echo 'Deploying Hello Jenkins!...'
                                }
                            }
                        }
                    }
                }

              
                stage('Hello Devops!') {
                    when {
                        beforeAgent true
                        changeset "hello-devops/**"
                    }
                    agent { label 'maven' }
                    stages {
                        stage('Build') {
                            steps {
                                dir('hello-devops') {
                                    sh 'mvn clean package'
                                }
                            }
                        }
                        stage('Test') {
                            steps {
                                dir('hello-devops') {
                                    sh 'mvn test'
                                }
                            }
                        }
                        stage('Deploy') {
                            steps {
                                dir('hello-devops') {
                                    echo 'Deploying Hello Devops!...'
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
