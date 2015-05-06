"use strict"
async = require 'async'
fs = require 'fs'
path = require 'path'
url = require 'url'

module.exports = (env, callback) ->

  class TocMarkdownPage extends env.plugins.MarkdownPage
    constructor: (@filepath, @metadata, @markdown) ->

    getPluginColor: () ->
      return 'yellow'

  TocMarkdownPage.fromFile = (filepath, callback) ->
    async.waterfall [
      (callback) ->
        fs.readFile filepath.full, callback
      (buffer, callback) ->
        TocMarkdownPage.extractMetadata buffer.toString(), callback
      (result, callback) =>
        {markdown, metadata} = result
        if metadata.toc
          # this document has the TOC flag.  Generate TOC
          # look for each "#
          markdown = "<div class=\"alert alert-info\">TOC Goes Here</div>\n\n" + markdown
        page = new this filepath, metadata, markdown
        callback null, page
    ], callback
    
  # register the plugins
  env.registerContentPlugin 'pages', '**/*.*(markdown|mkd|md)', TocMarkdownPage

  # done!
  callback()

