module.exports = {
  plugins: [
    require("postcss-import-ext-glob"),
    require("postcss-import"),
    require("postcss-mixins"),
    require("postcss-url")(
      {
        filter: /webfonts\/fa-/,
        url: "copy",
        basePath: "../../../../node_modules/@fortawesome/fontawesome-free/css",
        assetsPath: "../fonts",
        useHash: true
      },
      { filter: "**/*.svg", url: "inline", basePath: "../images" }
    ),
    require("postcss-preset-env")({ stage: 1 }),
    require("postcss-calc")({ precision: 10 }),
    require("autoprefixer"),
    require("postcss-discard-duplicates")
  ]
};
