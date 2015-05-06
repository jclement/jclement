"use strict"
async = require 'async'
fs = require 'fs'
path = require 'path'
url = require 'url'

repeat =  (str, n) ->
  res = ''
  while n > 0
    res += str if n & 1
    n >>>= 1
    str += str
  res

module.exports = (env, callback) ->

  class TocMarkdownPage extends env.plugins.MarkdownPage
    constructor: (@filepath, @metadata, @markdown) ->

    getPluginColor: () ->
      return 'yellow'

  TocMarkdownPage.generateId = (text) ->
    text.replace /\s/g, '-'
        .replace /%([abcdef]|\d){2,2}/ig, ''
        .replace /[\/?!:\[\]`.,()*"';{}+=<>~\$]/g,''
        .toLowerCase()
    

  TocMarkdownPage.fromFile = (filepath, callback) ->
    async.waterfall [
      (callback) ->
        fs.readFile filepath.full, callback
      (buffer, callback) ->
        TocMarkdownPage.extractMetadata buffer.toString(), callback
      (result, callback) =>
        {markdown, metadata} = result
        if metadata.toc
          toc = ''
          # this document has the TOC flag.  Generate TOC
          # look for each 

          maxLevel = 3
          
          if metadata.tocLevel
            maxLevel = metadata.tocLevel

          levels = []

          for header in markdown.match /^#+.*/mg
            match = header.match /^(#+)\s*(.*?)\s*#*\s*$/
            level = match[1].length
            title = match[2]
            link = TocMarkdownPage.generateId title
            levels.push [level, title, link]
          minLevel = 99
          for [level, title, link] in levels
            if level < minLevel
              minLevel = level
          for [level, title, link] in levels
            if level <= maxLevel 
              toc += repeat('  ', level-minLevel) + '- [' + title + '](#' + link + ')\n'
          markdown = toc + '\n\n' + markdown
        page = new this filepath, metadata, markdown
        callback null, page
    ], callback

  # register the plugins
  env.registerContentPlugin 'pages', '**/*.*(markdown|mkd|md)', TocMarkdownPage

  # done!
  callback()

