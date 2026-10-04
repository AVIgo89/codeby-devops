pipeline {
    agent none // Важно: используем agent none, чтобы избежать дедлока исполнителей [citation:2]

    stages {
        stage('Check Changes and Build in Parallel') {
            parallel {
                // Параллельная ветка для приложения Hello World!
                stage('Hello World!') {
                    // Запускаем только если в коммите изменились файлы в папке hello-world/
                    when {
                        beforeAgent true
                        changeset "hello-world/**"
                    }
                    agent { label 'maven' } // Ваш агент с меткой maven
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
                                    // Здесь можно добавить команду запуска, например:
                                    // sh 'java -jar target/*.jar &'
                                }
                            }
                        }
                    }
                }

                // Параллельная ветка для приложения Hello Jenkins!
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

                // Параллельная ветка для приложения Hello Devops!
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
