[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=visarnik_DevOpsUpskillDemo&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=visarnik_DevOpsUpskillDemo) [![Build App](https://github.com/visarnik/DevOpsUpskillDemo/actions/workflows/ci-build.yaml/badge.svg)](https://github.com/visarnik/DevOpsUpskillDemo/actions/workflows/ci-build.yaml) 
[![SonarCloud](https://sonarcloud.io/images/project_badges/sonarcloud-white.svg)](https://sonarcloud.io/summary/new_code?id=visarnik_DevOpsUpskillDemo) 
# Node.js - Demo Web Application

### Pre-reqs
This demo is configured to run on Amazon EKS, so you will need the following:
  - Terraform required_version = ">= 0.14"
  - AWS cli v2
  - kubectl 1.23.0
 
 ### Build AWS infrastructure 
 Configure aws cli
 ```bash
 $ aws configure
AWS Access Key ID [None]: <your AWS Access Key ID >
AWS Secret Access Key [None]: < your  AWS Secret Access Key >
Default region name [None]: us-west-2
Default output format [None]: json
 ```
  Clone the repo from github
  ```bash
git clone https://github.com/visarnik/DevOpsUpskillDemo.git
```
move to terraform directory and run terraform plan
  ```bash
cd terraform
```
 ```bash
 terraform apply
 ```
when terraform is done add newly created cluster to kubectl config
```bash
aws eks --region us-east-2 update-kubeconfig --name devops-demo
```
Create two DNS records - one for argocd and one for demo app itself and point them to the coresponding loadbalancer for EKS cluster
```bash
argocd.tick42.com
devops-demo.tick42.com
```
get your argocd web interface passwrod
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```
default argocd user is  `admin` <br />
Now you can login and check status of your demo application


### Makefile

A standard GNU Make file is provided to help with running and building locally.

```txt
$ make

help                 💬 This help message
lint                 🔎 Lint & format, will not fix but sets exit code on error
lint-fix             📜 Lint & format, will try to fix errors and modify code
image                🔨 Build container image from Dockerfile
push                 📤 Push container image to registry
run                  🏃 Run locally using Node.js
deploy               🚀 Deploy to Azure Container App
undeploy             💀 Remove from Azure
test                 🎯 Unit tests with Jest
test-report          🤡 Unit tests with Jest & Junit output
test-api             🚦 Run integration API tests, server must be running
clean                🧹 Clean up project
```


Web app will be listening on the standard Express port of 3000, but this can be changed by setting the `PORT` environmental variable.


# GitHub Actions CI/CD

GitHub Actions  are included for CI / CD. Automated builds  are run in GitHub hosted runners validating the code (linting, tests and SAST) and building the docker images. When code is pushed  into master, then automated deployment to EKS is done using argocd.

# Add new app to EKS

Create coresponding manifest for argocd and put it into `argocd` folder
Create Kubernetes manifests for your application using `Kustomize` and upload them into `Kubernetes` folder 



### Weather Details

Enable this by setting `WEATHER_API_KEY`

This will require a API key from OpenWeather, you can [sign up for free and get one here](https://openweathermap.org/price). The page uses a browser API for geolocation to fetch the user's location.  
However, the `geolocation.getCurrentPosition()` browser API will only work when the site is served via HTTPS or from localhost. As a fallback, weather for London, UK will be show if the current position can not be obtained

# Configuration

The following configuration environmental variables are supported, however none are mandatory. These can be set directly or when running locally will be picked up from an `.env` file if it is present. A sample `.env` file called `.env.sample` is provided for you to copy

If running in an Azure Web App, all of these values can be injected as application settings in Azure.

| Environmental Variable         | Default | Description                                                                      |
| ------------------------------ | ------- | -------------------------------------------------------------------------------- |
| PORT                           | 3000    | Port the server will listen on                                                   |
| TODO_MONGO_CONNSTR             | _none_  | Connect to specified MongoDB instance, when set the todo feature will be enabled |
| TODO_MONGO_DB                  | todoDb  | Name of the database in MongoDB to use (optional)                                |
| APPINSIGHTS_INSTRUMENTATIONKEY | _none_  | Enable Application Insights monitoring                                           |
| WEATHER_API_KEY                | _none_  | OpenWeather API key. [Info here](https://openweathermap.org/api)                 |
| AAD_APP_ID                     | _none_  | Application ID of app registered in Azure AD                                     |
| AAD_APP_SECRET                 | _none_  | Secret / password of app registered in Azure AD                                  |
| AAD_REDIRECT_URL_BASE          | _none_  | Hostname/domain where app is running                                             |


