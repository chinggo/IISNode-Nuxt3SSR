module.exports = {
  apps: [
    {
      name: "My-Nuxt3-App",
      exec_mode: "cluster",
      instances: "max",
      script: "./.output/server/index.mjs",
    },
  ],
};
