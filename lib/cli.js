const cac = require('cac')
const fs = require('fs')
const fse = require('fs-extra');
const cli = cac('create-lambda-typescript-function')
cli
    .command('[out-dir]', 'Generate in a custom directory or current directory')
    .action((outDir = 'my-lambda-app', cliOptions) => {
        console.log(outDir)
        if (fs.existsSync(outDir) && fs.readdirSync(outDir).length && !overwriteDir) {
            const baseDir = outDir === '.' ? path.basename(process.cwd()) : outDir
            return console.error(chalk.red(
                `Could not create project in ${baseDir} because the directory is not empty.`))
        }
        console.log(`✨  Generating lambda project in ${outDir}`)
        fse.copySync(`${__dirname}/../template`, `${outDir}`);
    })
    cli.parse()
