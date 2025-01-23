#!/bin/bash
sudo yum update -y
sudo yum install java-11-openjdk-devel -y
sudo yum install git maven -y
sudo hostnamectl set-hostname maven
