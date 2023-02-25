#!/usr/bin/env node
const cac = require('cac');
const { exec } = require('child_process');
const fs = require('fs')
const fse = require('fs-extra');
const cli = cac('create-lambda-typescript-function')
cli
    .command('[out-dir]', 'Generate in a custom directory or current directory')
    .option('--s3', 'Install S3 Client')
    .option('--lambda', 'Install Lambda Client')
    .option('--cloudwatch', 'Install Cloudwatch Client')
    .action((outDir = 'my-lambda-app', cliOptions) => {
        console.log(`outDir: ${outDir}`);
        if (fs.existsSync(outDir) && fs.readdirSync(outDir).length && !overwriteDir) {
            const baseDir = outDir === '.' ? path.basename(process.cwd()) : outDir
            return console.error(chalk.red(
                `Could not create project in ${baseDir} because the directory is not empty.`))
        }
        console.log(`✨  Generating lambda project in ${outDir}`);
        fse.copySync(`${__dirname}/../template`, `${outDir}`);
        exec(`cd ${outDir} && yarn install`, (err, stdout, stderr) => {
            if (err) {
                console.error(err);
                return;
            }
            let dependencies = '';
            if(cliOptions.s3){
                dependencies += '@aws-sdk/client-s3 ';
            }
            if(cliOptions.lambda){
                dependencies += '@aws-sdk/client-lambda ';
            }
            if(cliOptions.cloudwatch){
                dependencies += '@aws-sdk/client-cloudwatch ';
            }
            if(dependencies){
                exec(`cd ${outDir} && yarn add ${dependencies}`, (err, stdout, stderr) => {
                    if (err) {
                        console.error(err);
                        return;
                    }
                    console.log(`🎉  Successfully created project ${outDir}. with ${dependencies}`)
                });
            }else{
                console.log(`🎉  Successfully created project ${outDir}.`)
            }
        });
    })
    cli.parse()
