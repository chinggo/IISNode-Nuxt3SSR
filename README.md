# Note Nuxt3 Publish to IISNode Process

## Nuxt3 Setup

Make sure to install the dependencies:

```bash
# yarn
yarn install

# npm
npm install

# pnpm
pnpm install
```

## Check the IISNode dependencies was install
1. Nodejs
2. IISNode Module
3. URL Rewrite

## Publish to the IISNode
1. Package the Nuxt3 Project
2. Config IIS and Application Pool
3. Copy the web.config、server.js to the root folder

## Docker command
```
# build 
docker build -t nuxt-app .

# run
docker run -d -p 3000:3000 nuxt-app
```

Check the http://localhost:3000

Check out the [documentation](https://hackmd.io/V3VSjUpLS2yE6EwVYCJR8g?both) for more information.
