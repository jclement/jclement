module.exports = function(env, callback) {

  var _ = require('underscore');

  env.helpers.getArticles = function(contents) {
    articles = [];

    // assume articles in structure /articles/YEAR/NAME/index.md

    _.each(contents['articles']._.directories, function(year) {
      _.chain(year._.directories)
      .map(function(pair) {
        return pair['index.md'];
      })
      .each(function(article) {
        articles.push(article);
      });
    });

    return _.chain(articles)

      // filter out articles with no template
      .filter(function(article) {
        return !!article.template;
      })

      // sort by date (and reverse)
      .sortBy(function(article) {
        return article.date
      })
      .reverse()

      .value();

  };

  callback();
};
