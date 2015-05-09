"use strict"

# intercept markdown, generate TOC and add it to page prior to Marked running
# usage:
#  - only applies to pages with "toc: true" in metadata.
#  - customize max depth with "tocLevel: 3"
# known issues:
#  - doesn't support <h#> tags or underlined headers
#  - doesn't handle repeated headers

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
    text.replace(/\s/g, '-')
        .replace(/%([abcdef]|\d){2,2}/ig, '')
        .replace(/[\/?!:\[\]`.,()*"';{}+=<>~\$]/g,'')
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

          # find headers (## style only ##)
          in_code = false
          for line in markdown.split '\n'
            # look for code blocks and ignore headings until close of code block
            if line.match /^```/
              in_code = !in_code
            # if not in code block and starts with #, heading
            if !in_code && line.match /^#/
              match = line.match /^(#+)\s*(.*?)\s*#*\s*$/
              level = match[1].length
              title = match[2]
              link = TocMarkdownPage.generateId title
              levels.push [level, title, link]

          # find minimum level so we can normalize TOC to start at level-1
          minLevel = 99
          for [level, title, link] in levels
            if level < minLevel
              minLevel = level

          # draw TOC as MD list
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

