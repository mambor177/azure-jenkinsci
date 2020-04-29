# copy file from pod
kubectl cp jenkins/jenkins-6fb46f987b-hh5jj:/var/jenkins_home/config.xml ./master_config.xml

kubectl cp ./master_config.xml jenkins/jenkins-7bc8cc655d-wnkq2:/var/jenkins_home/config.xml
