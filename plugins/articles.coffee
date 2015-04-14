
module.exports = (env, callback) ->

  defaults =
    articles: 'articles' # directory containing contents to paginate

  # assign defaults any option not set in the config file
  options = env.config.paginator or {}
  for key, value of defaults
    options[key] ?= defaults[key]

  getArticles = (contents) ->
    # helper that returns a list of articles found in *contents*
    # note that each article is assumed to have its own directory in the articles directory
    articles = contents[options.articles]._.directories.map (item) -> item.index
    # skip articles that does not have a template associated
    articles = articles.filter (item) -> item.template isnt 'none'
    # sort article by date
    articles.sort (a, b) -> b.date - a.date
    return articles

  # add the article helper to the environment so we can use it later
  env.helpers.getArticles = getArticles

  # tell the plugin manager we are done
  callback()
