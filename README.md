[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=visarnik_DevOpsUpskillDemo&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=visarnik_DevOpsUpskillDemo) [![Build App](https://github.com/visarnik/DevOpsUpskillDemo/actions/workflows/ci-build.yaml/badge.svg)](https://github.com/visarnik/DevOpsUpskillDemo/actions/workflows/ci-build.yaml) 
[![SonarCloud](https://sonarcloud.io/images/project_badges/sonarcloud-white.svg)](https://sonarcloud.io/summary/new_code?id=visarnik_DevOpsUpskillDemo) 
# Node.js - Demo Web Application

### Pre-reqs
This demo is configured to run on Amazon EKS, so you will need the following:
  - Terraform required_version = ">= 0.14"
  - AWS cli v2
  - kubectl 1.23.0
 
 ### Build AWS infrastructure 
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
Create to DNS records - one for argocd and one for demo app itself and point them to the coresponding loadbalancer for EKS cluster

# Running and Testing Locally

### Pre-reqs

- Be using Linux, WSL or MacOS, with bash, make etc
- [Node.js](https://nodejs.org/en/) - for running locally, linting, running tests etc
- [Docker](https://docs.docker.com/get-docker/) - for running as a container, or building images
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux) - for deployment to Azure

Clone the project to any directory where you do development work

```bash
git clone https://github.com/benc-uk/nodejs-demoapp.git
```

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

Make file variables and default values, pass these in when calling `make`, e.g. `make image IMAGE_REPO=blah/foo`

| Makefile Variable | Default                |
| ----------------- | ---------------------- |
| IMAGE_REG         | ghcr<span>.</span>io   |
| IMAGE_REPO        | benc-uk/nodejs-demoapp |
| IMAGE_TAG         | latest                 |
| AZURE_RES_GROUP   | demoapps               |
| AZURE_REGION      | northeurope            |

Web app will be listening on the standard Express port of 3000, but this can be changed by setting the `PORT` environmental variable.

# Containers

Public container image is [available on GitHub Container Registry](https://github.com/users/benc-uk/packages/container/package/nodejs-demoapp).

Run in a container with:

```bash
docker run --rm -it -p 3000:3000 ghcr.io/benc-uk/nodejs-demoapp:latest
```

Should you want to build your own container, use `make image` and the above variables to customise the name & tag.

## Kubernetes

The app can easily be deployed to Kubernetes using Helm, see [deploy/kubernetes/readme.md](deploy/kubernetes/readme.md) for details

# GitHub Actions CI/CD

A set of GitHub Actions workflows are included for CI / CD. Automated builds for PRs are run in GitHub hosted runners validating the code (linting and tests) and building dev images. When code is merged into master, then automated deployment to AKS is done using Helm.

[![](https://img.shields.io/github/workflow/status/benc-uk/nodejs-demoapp/CI%20Build%20App)](https://github.com/benc-uk/nodejs-demoapp/actions?query=workflow%3A%22CI+Build+App%22) [![](https://img.shields.io/github/workflow/status/benc-uk/nodejs-demoapp/CD%20Release%20-%20AKS?label=release-kubernetes)](https://github.com/benc-uk/nodejs-demoapp/actions?query=workflow%3A%22CD+Release+-+AKS%22) 

# Optional Features

The app will start up and run with zero configuration, however the only features that will be available will be the INFO and TOOLS views. The following optional features can be enabled:

### Application Insights

Enable this by setting `APPINSIGHTS_INSTRUMENTATIONKEY`

The app has been instrumented with the Application Insights SDK, it will however need to be configured to point to your App Insights instance/workspace. All requests will be tracked, as well as dependant calls to MongoDB or other APIs (if configured), exceptions & error will also be logged

[This article](https://docs.microsoft.com/azure/application-insights/app-insights-nodejs) has more information on monitoring Node.js with App Insights

### Weather Details

Enable this by setting `WEATHER_API_KEY`

This will require a API key from OpenWeather, you can [sign up for free and get one here](https://openweathermap.org/price). The page uses a browser API for geolocation to fetch the user's location.  
However, the `geolocation.getCurrentPosition()` browser API will only work when the site is served via HTTPS or from localhost. As a fallback, weather for London, UK will be show if the current position can not be obtained

### User Authentication with Azure AD

Enable this by setting `AAD_APP_ID`, `AAD_APP_SECRET`

This uses [Microsoft Authentication Library (MSAL) for Node](https://github.com/AzureAD/microsoft-authentication-library-for-js/tree/dev/lib/msal-node) to authenticate via MSAL with OIDC and OAuth 2.0. The flow it uses is the "OAuth 2.0 Authorization Code Grant", which is standard for server side (confidential) apps.

In addition the user account page shows details & photo retrieved from the Microsoft Graph API

You will need to register an app in your Azure AD tenant. [See this guide](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app). Add a secret to your app and use the app's ID & secret value in `AAD_APP_ID` & `AAD_APP_SECRET`. When registering the app for authentication the redirect URL will be the host where the app is running with `/signin` as the URL path


### Todo App

Enable this by setting `TODO_MONGO_CONNSTR`

A mini todo & task tracking app can be enabled if a MongoDB backend is provided and a connection string to access it. This feature is primarily to show database dependency detection and tracking in App Insights

The default database name is `todoDb` but you can change this by setting `TODO_MONGO_DB`

You can stand up MongoDB in a container instance or in Cosmos DB (using the Mongo API). Note. When using Cosmos DB and the _per database provisioned RU/s_ option, you must manually create the collection called `todos` in the relevant database and set the shard key to `_id`

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

## Deployment

See [deployment folder](./deploy) for deploying into Kubernetes with Helm or into Azure with Bicep and Container Apps.

