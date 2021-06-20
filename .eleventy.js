const htmlmin = require("html-minifier");
const markdownIt = require('markdown-it');
const pluginRss = require("@11ty/eleventy-plugin-rss");
const mdClass = require("@toycode/markdown-it-class");
const Image = require("@11ty/eleventy-img");

// https://www.11ty.dev/docs/plugins/image/#use-this-in-your-templates
async function imageShortcode(src, alt, cls) {
  let metadata = await Image(src, {
    widths: [300, 600, null],
    formats: ["webp", "jpeg"],
    urlPath: "/img/generated/",
    outputDir: "./src/static/img/generated/",
  });

  const sizes = "(min-width: 30em) 50vw, 100vw";

  const imageAttributes = {
    class: cls,
    alt,
    sizes,
    loading: "lazy",
    decoding: "async",
  };

  return Image.generateHTML(metadata, imageAttributes, {
    whitespaceMode: "inline"
  });
}

module.exports = function (eleventyConfig) {
  // PLUGINS
  eleventyConfig.addPlugin(pluginRss);

  // Image shortcodes
  eleventyConfig.addNunjucksAsyncShortcode("image", imageShortcode);
  eleventyConfig.addLiquidShortcode("image", imageShortcode);
  eleventyConfig.addJavaScriptFunction("image", imageShortcode);

  // shortcode to render markdown from string => {{ STRING | markdown | safe }}
  eleventyConfig.addFilter('markdown', function(value) {
    let markdown = require('markdown-it')({
      html: true
    });
    return markdown.render(value);
  });

  // rebuild on CSS changes
  eleventyConfig.addWatchTarget('./src/_includes/css/');

  // Markdown
  eleventyConfig.setLibrary(
    'md',
    markdownIt({
      html: true,
      breaks: true,
      linkify: true,
      typographer: true
    })
      .use(mdClass, {
        h2: "text-2xl font-bold"
      })
  )

  //create collections
  eleventyConfig.addCollection('sections', async (collection) => {
    return collection.getFilteredByGlob('./src/sections/*.md');
  });

  // STATIC FILES
  eleventyConfig.addPassthroughCopy({ './src/static/': '/' });

  // TRANSFORM -- Minify HTML Output
  eleventyConfig.addTransform("htmlmin", function(content, outputPath) {
    if( outputPath && outputPath.endsWith(".html") ) {
      let minified = htmlmin.minify(content, {
        useShortDoctype: true,
        removeComments: true,
        collapseWhitespace: true
      });
      return minified;
    }
    return content;
  });

  return {
    dir: {
      input: 'src',
      output: 'public',
      data: './_data',
      includes: './_includes',
      layouts: './_layouts'
    },
    templateFormats: [
      'md',
      'njk',
      '11ty.js'
    ],
    htmlTemplateEngine: 'njk'
  };
};