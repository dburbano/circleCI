#!/bin/bash

GITHUB_REPO=$1
GITHUB_BRANCH=$2
PIPELINE_ENV=$3
ARTIFACT_ENV=$4

BUCKET_REPO="mach-mobile-automation-repos"
TEST_REPO="test"
IOS_REPO="ios"
ANDROID_REPO="android"

PROJECT_NAME="pipeline-ios-project"
PROJECT_ARN="arn:aws:devicefarm:us-west-2:425782179927:project:69683c23-ccfb-4308-b0f8-33f34d6098e0"

IPA_FILE="MyFile.ipa"
IPA_OUTPUT_FILE="ipa-output.log"

TEST_OUTPUT_FILE="test-output.log"
AVAILABLE_TESTS=available-ios-tests
TEST_ARN_LIST_FILE=smoke-test-arn-list

DEVICE_POOL_NAME="ApplePhone"
DEVICE_POOL_ARN="arn:aws:devicefarm:us-west-2:425782179927:devicepool:69683c23-ccfb-4308-b0f8-33f34d6098e0/67db20ae-9259-439a-ad35-bf29773e5ce4"

RUN_NAME="Smoke-Test"
RUN_OUTPUT_FILE="run-output.log"

echo "========= PIPELINE IMPORTED VARIABLES ============"
echo "REPO: $GITHUB_REPO"
echo "BRANCH: $GITHUB_BRANCH"
echo "PIPELINE ENVIRONMENT: $PIPELINE_ENV"
echo "ARTIFACT ENVIRONMENT: ${ARTIFACT_ENV}"

echo "========= PIPELINE ENVIRONMENT ==========="
case $PIPELINE_ENV in
	       "ops")ENV="-ops";;
	   "develop")ENV="-dev";;
	"production")ENV="-prod";;
	   "staging")ENV="-staging";;
	           *)ENV="-ops";;
esac
echo "PIPELINE ENVIRONMENT --> ENV: ${PIPELINE_ENV}  -->  ${ENV}"

echo "========= ARTIFACT ENVIRONMENT ==========="
case $ARTIFACT_ENV in
	   "develop")IPA_FILE="machApp-dev.ipa";;			 
	"automation")IPA_FILE="machApp-automation.ipa";;
	"production")IPA_FILE="machApp-production.ipa";;
	   "staging")IPA_FILE="machApp-staging.ipa";;
esac
echo "PIPELINE ENVIRONMENT --> IPA_FILE: ${PIPELINE_ENV}  -->  ${IPA_FILE}"

echo "================================================"
echo "====== STEP 1. Create a device farm project ===="
echo "================================================"

echo "The project for this test pipeline-ios-project"

echo "================================================="
echo "===== STEP 2. Create an upload iOS IPA File ====="
echo "================================================="

echo "The IPA file is created in the previos stage and pass in the artifact"
pwd


#IPA_FILE="`ls *.ipa`"
aws devicefarm create-upload --project-arn $PROJECT_ARN --name $IPA_FILE --type IOS_APP > $IPA_OUTPUT_FILE
IPA_ARN="`cat $IPA_OUTPUT_FILE | grep "arn:"| sed 's/"arn": //'| sed 's/ //g'| sed 's/[",]//g'`"
IPA_PRESIGNED_URL="`cat $IPA_OUTPUT_FILE | grep "url" | sed 's/"url"://g'|sed 's/[",]//g'`" 
curl -T $IPA_FILE $IPA_PRESIGNED_URL
sleep 60

echo "================================================="
echo "===== STEP 3. Create an upload test package ====="
echo "================================================="

aws s3 cp s3://$BUCKET_REPO/$TEST_REPO/$AVAILABLE_TESTS ./$AVAILABLE_TESTS
LIST_AVAILABLE_TEST=( `sed ':a;N;$!ba;s/\n/ /g' ./$AVAILABLE_TESTS` )
echo $LIST_AVAILABLE_TEST

for TEST_FILE in ${LIST_AVAILABLE_TEST[@]}; do
	aws s3 cp s3://$BUCKET_REPO/$TEST_REPO/${TEST_FILE}${ENV}.zip ./${TEST_FILE}${ENV}.zip
	aws devicefarm create-upload --project-arn $PROJECT_ARN --name ${TEST_FILE}${ENV}.zip --type APPIUM_JAVA_TESTNG_TEST_PACKAGE > $TEST_OUTPUT_FILE
	TEST_ARN="`cat $TEST_OUTPUT_FILE | grep "arn":| sed 's/"arn": //'| sed 's/ //g'| sed 's/[",]//g'`"
	echo "${TEST_FILE}|${TEST_ARN}" >> ./$TEST_ARN_LIST_FILE
	TEST_PRESIGNED_URL="`cat $TEST_OUTPUT_FILE| grep "url" | sed 's/"url"://'|sed 's/[",]//g'`"
	curl -T ${TEST_FILE}${ENV}.zip $TEST_PRESIGNED_URL
	sleep 60
done

echo "===================================================================="
echo "===== STEP 4. Create a device pool associated with the Project ====="
echo "===================================================================="

echo "There is a device pool ($DEVICE_POOL_NAME) associated to the project name $PROJECT_NAME"

echo "===================================="
echo "----- STEP 5. Schedule the Run -----"
echo "===================================="

echo "PROJECT ARN: $PROJECT_ARN"
echo "IPA ARN: $IPA_ARN"
echo "DEVICE POOL ARN: $DEVICE_POOL_ARN"
echo "RUN NAME: $RUN_NAME"

SUFFIX=`date +"%s"`
for TEST_ARN_LINE in `cat ./$TEST_ARN_LIST_FILE`; do
    TEST_ARN=${TEST_ARN_LINE##*|}
	RUN_NAME="S${ENV}-${TEST_ARN_LINE%%|*}"
	sed 's|REPLACE_TEST_ARN|'"${TEST_ARN}"'|g' ./config/template-test.json > ./config/smoke.json
	aws devicefarm schedule-run --project-arn $PROJECT_ARN --app-arn $IPA_ARN --device-pool-arn $DEVICE_POOL_ARN --name "${RUN_NAME}-${SUFFIX}" --test file://./config/smoke.json > $RUN_OUTPUT_FILE
done		  
