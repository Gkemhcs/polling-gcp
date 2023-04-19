#! /bin/bash
echo "WE ARE ABOUT TO START"
echo "creating project"
echo "ENTER YOUR PROJECT ID:-"
read PROJECT_ID
echo "enter the name you want to display for your project:-"
read PROJECT_NAME
gcloud projects create $PROJECT_ID --name $PROJECT_NAME --set-as-default
export BILLING_ACCOUNT_ID=$(gcloud beta billing accounts  list --format "value(ACCOUNT_ID)")
gcloud beta billing projects link $PROJECT_ID --billing-account $BILLING_ACCOUNT_ID
echo "SUCCESSFULLY LINKED PROJECT TO BILLING ACCOUNT ID $BILLING_ACCOUNT_ID"
echo "enabling the cloudrun,cloudbuild,artifactregistry,datastore apis"
gcloud services enable run.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com datastore.googleapis.com firestore.googleapis.com
echo "ALL THE REQUIRED SERVICES ENABLED ✅"
echo "enter the location in which you want to deploy your datastore instance"
echo "⚠️:-TRY TO PUT ALL YOUR  RESOURCES IN SAME LOCATION FOR BETTER LATENCY"
read DATASTORE_LOCATION
gcloud alpha firestore databases create --location $DATASTORE_LOCATION --type datastore-mode  
echo "CREATING ARTIFACT REPOSITORY FOR IMAGES"
echo "ENTER THE CLOUD RUN REGION IN WHICH YOU WANT TO DEPLOY YOUR SERVICE"
read REGION
gcloud artifacts repositories create poll-repo --location $REGION --description "polling image" --repository-format docker --labels=image=poll,deploy=run
echo "ARTIFACT REPOSITORY NAMED poll-repo CREATED IN ${REGION}"
echo "BUILDING DOCKER IMAGE 🔄"
cd code
export PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format "value(projectNumber)")
export CLOUDBUILD_SERVICE_ACCOUNT=${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com
gcloud artifacts repositories add-iam-policy-binding poll-repo --location $REGION --member "serviceAccount:${CLOUDBUILD_SERVICE_ACCOUNT}" \
 --role roles/artifactregistry.writer
gcloud  builds submit --pack image=$REGION-docker.pkg.dev/pushpavathi-143/poll-repo/poll-image
echo "image successfully built"
echo "here we have to initialise the database and count with 0"
cd init-database
npm i @google-cloud/datastore
npm start
cd ..
echo "CREATING SERVICEACCOUNT FOR CLOUD RUN SERVICE"
export SERVICE_ACCOUNT_NAME=datastore-user
gcloud iam service-accounts create datastore-user --display-name datastoreuser 
gcloud projects add-iam-policy-binding $PROJECT_ID --member "serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" --role roles/datastore.user
echo "DEPLOYING CLOUD RUN RESOURCE "
echo "ENTER THE RUN-SERVICE NAME"
read RUN_NAME
gcloud run deploy $RUN_NAME --region $REGION --image  $REGION-docker.pkg.dev/pushpavathi-143/poll-repo/poll-image \
--allow-unauthenticated \
--service-account "${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
export url=$(gcloud run services describe $RUN_NAME --region us-central1 --format "value(status.address.url)")
echo "run service url is ${url}"

