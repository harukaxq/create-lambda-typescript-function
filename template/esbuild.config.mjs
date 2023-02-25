import {sentryEsbuildPlugin} from '@sentry/esbuild-plugin'
import { build } from 'esbuild'

build({
  entryPoints: ['src/index.ts'],
  outfile: '.build/index.js',
  sourcemap: true,
  platform: 'node',
  bundle: true,
  plugins: [
    sentryEsbuildPlugin({
      include: './.build/',
      ignore: ['esbuild.config.js'],

      url: process.env.SENTRY_URL || 'https://sentry.io',
      org: 'cibo',
      project: process.env.SENTRY_PROJECT_NAME,
      authToken: process.env.SENTRY_AUTH_TOKEN,
      release: process.env.SENTRY_RELEASE,
    }),
  ],
})
