const fs = require('fs');
const path = require('path');
const postcss = require('postcss');

module.exports = class {
  async data() {
    const cssDir = path.join(__dirname, '..', '_includes', 'css');
    const rawFilepath = path.join(cssDir, '_page.css');

    return {
      permalink: `css/page.css`,
      rawFilepath,
      rawCss: fs.readFileSync(rawFilepath),
    };
  }

  async render({ rawCss, rawFilepath }) {
    return await postcss([
      require('postcss-import'),
      require('autoprefixer'),
      require('tailwindcss')(require("./tailwind.config.js")),
      require('cssnano')
    ])
      .process(rawCss, { from: rawFilepath })
      .then((result) => {console.log("processed CSS");return result.css});
  }
};