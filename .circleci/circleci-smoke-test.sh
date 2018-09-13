#!/bin/bash

###################################################
## Script sends a smoke test to AWS Device Farm ###
###################################################

echo "===================================================="
echo "==== Environment Variables loaded from CircleCI ===="
echo "===================================================="
echo "BUCKET_REPO: ${BUCKET_REPO}"
echo "TEST_REPO: ${TEST_REPO}"
echo "PROJECT_NAME: ${PROJECT_NAME}"
echo "PROJECT_ARN: ${PROJECT_ARN}"
echo "DEVICE_POOL_NAME: ${DEVICE_POOL_NAME}"
echo "DEVICE_POOL_ARN: ${DEVICE_POOL_ARN}"
echo "RUN_NAME: ${RUN_NAME}"
echo "IPA_PATH: ${IPA_PATH}"
echo "IPA_FILE: ${IPA_FILE}"
echo "IPA_OUTPUT_LOG: ${IPA_OUTPUT_LOG}"
echo "TEST_OUTPUT_LOG: ${TEST_OUTPUT_LOG}"
echo "CIRCLECI_DIR: ${CIRCLECI_DIR}"
echo "PLATFORM: ${PLATFORM}"
echo "ENV: ${ENV}"
echo "===================================================="

echo "================================================"
echo "====== STEP 1. Create a device farm project ===="
echo "================================================"

echo "Project name: ${PROJECT_NAME}"

echo "================================================="
echo "===== STEP 2. Create an upload iOS IPA File ====="
echo "================================================="

aws devicefarm create-upload --project-arn ${PROJECT_ARN} --name ${IPA_FILE} --type IOS_APP > ${IPA_OUTPUT_LOG}
IPA_ARN="`cat ${IPA_OUTPUT_LOG} | grep "arn:"| sed 's/"arn": //'| sed 's/ //g'| sed 's/[",]//g'`"
IPA_PRESIGNED_URL="`cat ${IPA_OUTPUT_LOG} | grep "url" | sed 's/"url"://g'|sed 's/[",]//g'`"
curl -T ${IPA_FILE} ${IPA_PRESIGNED_URL}
echo "${IPA_ARN}"
aws devicefarm get-upload --arn "${IPA_ARN}"

echo "================================================="
echo "===== STEP 3. Create an upload test package ====="
echo "================================================="

aws s3 cp s3://$BUCKET_REPO/$TEST_REPO/$AVAILABLE_TESTS ./$AVAILABLE_TESTS
LIST_AVAILABLE_TEST=( `sed ':a;N;$!ba;s/\n/ /g' ./$AVAILABLE_TESTS` )
echo $LIST_AVAILABLE_TEST
for TEST_FILE in ${LIST_AVAILABLE_TEST[@]}; do
    aws s3 cp s3://${BUCKET_REPO}/${TEST_REPO}/${TEST_FILE}${ENV}.zip ./${TEST_FILE}${ENV}.zip
    aws devicefarm create-upload --project-arn ${PROJECT_ARN} --name ${TEST_FILE}${ENV}.zip --type APPIUM_JAVA_TESTNG_TEST_PACKAGE > ${TEST_OUTPUT_LOG}
    TEST_ARN="`cat ${TEST_OUTPUT_LOG} | grep "arn":| sed 's/"arn": //'| sed 's/ //g'| sed 's/[",]//g'`"
    echo "${TEST_FILE}|${TEST_ARN}" >> ./${TEST_ARN_LIST_FILE}
    TEST_PRESIGNED_URL="`cat ${TEST_OUTPUT_LOG}| grep "url" | sed 's/"url"://'|sed 's/[",]//g'`"
    curl -T ${TEST_FILE}${ENV}.zip ${TEST_PRESIGNED_URL}
    aws devicefarm get-upload --arn "${TEST_ARN}"
    sleep 60
done

echo "===================================================================="
echo "===== STEP 4. Create a device pool associated with the Project ====="
echo "===================================================================="

echo "There is a device pool ($DEVICE_POOL_NAME) associated to the project name $PROJECT_NAME"

echo "===================================="
echo "----- STEP 5. Schedule the Run -----"
echo "===================================="

echo "PROJECT ARN: ${PROJECT_ARN}"
echo "TEST_ARN: ${TEST_ARN}"
echo "IPA ARN: ${IPA_ARN}"
echo "DEVICE POOL ARN: ${DEVICE_POOL_ARN}"
echo "RUN NAME: ${RUN_NAME}"
SUFFIX=`date +"%s"`
pwd
ls
for TEST_ARN_LINE in `cat ./${TEST_ARN_LIST_FILE}`; do
    TEST_ARN=${TEST_ARN_LINE##*|}
    RUN_NAME="S${ENV}-${TEST_ARN_LINE%%|*}"
    sed 's|REPLACE_TEST_ARN|'"${TEST_ARN}"'|g' ./${CIRCLECI_DIR}/template-test.json > ./${CIRCLECI_DIR}/smoke.json
    aws devicefarm schedule-run --project-arn ${PROJECT_ARN} --app-arn ${IPA_ARN} --device-pool-arn ${DEVICE_POOL_ARN} --name "${RUN_NAME}-CircleCI-${SUFFIX}" --test file://./${CIRCLECI_DIR}/smoke.json
done