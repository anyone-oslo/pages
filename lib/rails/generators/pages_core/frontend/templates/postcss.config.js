module.exports = {
  plugins: [
    require("postcss-import-ext-glob"),
    require("postcss-import"),
    require("postcss-image-inliner")({ assetPaths: ["app/assets/images"] }),
    require("postcss-mixins"),
    require("postcss-simple-vars"),
    require("postcss-preset-env")({ stage: 1 }),
    require("postcss-calc")({ precision: 10 }),
    require("autoprefixer"),
    require("postcss-discard-duplicates")
  ]
};
