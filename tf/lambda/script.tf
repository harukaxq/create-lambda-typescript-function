# docker-buildスクリプトを作成
resource "local_file" "ignoreifle" {
  filename = "./script/.gitignore"
  content  = "*"
}
resource "local_file" "docker-build" {
  count    = var.type == "docker" ? 1 : 0
  filename = "./script/${var.name}/docker-build.sh"
  content  = <<EOF
#!/bin/bash
cd ${abspath(var.build_path)}
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws
docker build -t ${module.build[0].image_uri} \
    --build-arg SENTRY_AUTH_TOKEN=${var.sentry_auth_token} \
    --build-arg SENTRY_URL=${var.sentry_base_url} \
    --build-arg SENTRY_PROJECT_NAME=${var.name} \
    --build-arg SENTRY_RELEASE=${var.name}@${data.archive_file.zip.output_sha} \
    .
EOF
}
resource "local_file" "docker-deploy" {
  count    = var.type == "docker" ? 1 : 0
  filename = "./script/${var.name}/docker-deploy.sh"
  content  = <<EOF
#!/bin/bash
cd `dirname $0`
bash docker-build.sh
cd ${abspath(var.build_path)}
docker push ${module.build[0].image_uri}
aws lambda update-function-code --function-name ${module.function.lambda_function_name} --image-uri ${module.build[0].image_uri}
awa lambda wait function-updated --function-name ${module.function.lambda_function_name}
echo "Deployed ${module.build[0].image_uri}"
EOF
}
# local-buildスクリプトを作成
resource "local_file" "local-build" {
  filename = "./script/${var.name}/local-build.sh"
  content  = <<EOF
#!/bin/bash
cd ${abspath(var.build_path)}
    SENTRY_AUTH_TOKEN=${var.sentry_auth_token} \
    SENTRY_URL=${var.sentry_base_url} \
    SENTRY_PROJECT_NAME=${var.name} \
    SENTRY_RELEASE=${var.name}@${data.archive_file.zip.output_sha} \
yarn build
EOF
}
# invoke-localスクリプトを作成
resource "local_file" "invoke-local" {
  filename = "./script/${var.name}/invoke-local.sh"
  content  = <<EOF
#!/bin/bash
cd ${abspath(var.build_path)}
    SENTRY_AUTH_TOKEN=${var.sentry_auth_token} \
    SENTRY_URL=${var.sentry_base_url} \
    SENTRY_PROJECT_NAME=${var.name} \
    SENTRY_RELEASE=${var.name}@${data.archive_file.zip.output_sha} \
yarn build
nodejs .build/index.js
  EOF
}

resource "local_file" "invoke-aws" {
  count    = var.create_script ? 1 : 0
  filename = "./script/${var.name}/invoke-aws.sh"
  content  = <<EOF
#!/bin/bash
cd ${abspath(var.build_path)}
    SENTRY_AUTH_TOKEN=${var.sentry_auth_token} \
    SENTRY_URL=${var.sentry_base_url} \
    SENTRY_PROJECT_NAME=${var.name} \
    SENTRY_RELEASE=${var.name}@${data.archive_file.zip.output_sha} \
yarn build
nodejs .build/index.js
  EOF
}
