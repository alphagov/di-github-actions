#!/bin/bash

cd "${GITHUB_WORKSPACE}""$BASE_PATH" || exit 1
rm -rf ./public
if [ "${NPM_OR_YARN}" == 'yarn' ]; then
  yarn install
fi
if [ "${NPM_OR_YARN}" == 'npm' ]; then
  npm install
fi
jq '.version' ./node_modules/govuk-frontend/package.json | tr -d '"' > ./govuk_fe_version.txt
thisversion=$(cat ./govuk_fe_version.txt)
sed "s/\(@import .*\/node_modules\/govuk-frontend\/govuk\/base\";\)/\$govuk-assets-path: \"\/v-$thisversion\/\"\n\1/" "$PATH_TO_SASS"
if [ "${NPM_OR_YARN}" == 'yarn' ]; then
  yarn build
fi
if [ "${NPM_OR_YARN}" == 'npm' ]; then
  npm build
fi
mv ./dist/public ./public
zip -r ./public.zip ./public/*
md5sum ./public.zip | cut -c -32 > zipsum.txt
aws kms sign --key-id "$ZIP_SIGNING_KEY" --message fileb://zipsum.txt --signing-algorithm RSASSA_PSS_SHA_256 --message-type RAW --output text --query Signature | base64 --decode > ZipSignature
zip -r ./"$STACK_NAME".zip ./public.zip ./ZipSignature ./govuk_fe_version.txt
aws s3 cp "$STACK_NAME".zip "s3://$ARTIFACT_BUCKET/$STACK_NAME.zip" --metadata "repository=$GITHUB_REPOSITORY,commitsha=$GITHUB_SHA"
echo "assets zip file uploaded"
