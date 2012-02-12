#!/usr/bin/env coffee

# usage and minimal parameter checking
if process.argv.length < 4
  console.log "usage: #{process.argv[1]} <languageConfig> <sourcefolder> [more folders]"
  return

# requires
fs = require('fs')
path = require('path')
async = require('async')
http = require('http')
url = require('url')

# gloabl config and language config
languageConfig = require('./' + process.argv[2] + '.languageConfig.js')

whitelist = languageConfig.whitelist
parseStart = languageConfig.parseStart
blacklist = languageConfig.blacklist

# global config
webRoot = 'webroot'
maxWords = 100
serverPort = 4242

directories = process.argv.splice(3)
globalWords = {}
globalWordsArray = []

# recursively open directory dir and all containing files, call cb when done
openDirectory = (dir, cb) ->
  fs.stat dir, (err, stats) ->
    if (err)
      console.log(err)
      return
    if (stats.isDirectory())
      fs.readdir dir, (err, files) ->
        if (err)
          console.log(err)
          return
        async.forEach(files.map((file)->
          path.join(dir, file)), openDirectory, cb)
        return
    if (stats.isFile())
      processFile(dir)
      cb(null)

# check if the file is intereisting for us, open when necessary
processFile = (file) ->
  if (file.match whitelist)
    console.log('processing ' + file)
    fs.readFile file, 'UTF-8', parseFile

# process-file callback
parseFile = (err, data) ->
  if (err)
    console.log(err)
    return
  lines = data.split('\n')
  greenLight = false
  for line in lines
    if greenLight || line.match parseStart
      greenLight = true
      processLine line

# process individual lines
# first, clean the line from non-letters (except the @)
# second split by words and check if they aren't blacklistet words
# finally, add them to the globalWords map
processLine = (line) ->
  cleaned = line.replace /[^0-9a-zA-Z@]/g, ' '
  words = cleaned.split ' '
  for word in words
    if word and blacklist.indexOf(word.trim()) < 0
      globalWords[word] = globalWords[word] || 0
      globalWords[word] += 1

# call back to be called when all files have been processed
processingFinished = () ->
  for word, count of globalWords
    globalWordsArray.push {text: word, size: count}
  globalWordsArray.sort (a,b) ->
    return -1 if a.size > b.size
    return 1 if a.size < b.size
    return 0
  console.log('Done parsing')
  #console.log globalWordsArray
  wordServer.listen serverPort

# start servers
wordServer = http.createServer (req, res) ->
  if req.url.match /^\/json/
    userLimit = url.parse(req.url, true).query['limit']
    words = userLimit || maxWords
    res.writeHead(200, {'Content-Type' : 'application/json'} )
    res.end JSON.stringify(globalWordsArray.slice(0,Math.min(words, globalWordsArray.length)))
    return
  uri = url.parse(req.url).pathname
  uri = '/cloud.html' if uri.match /\/$/
  filename = path.join process.cwd(), webRoot, uri
  path.exists filename, (exists) ->
    if not exists
      res.writeHead(404, {"Content-Type": "text/plain"})
      res.write("404 Not Found\n")
      res.end()
      return
    fs.readFile filename, 'binary', (err, file) ->
      if err
        res.writeHead 500, "Content-Type": "text/plain"
        res.write err
        res.end()
        return
      res.writeHead 200
      res.write file, 'binary'
      res.end()

# start procesing of input directories
# this sets the entire contraption into motion
async.forEach(directories, openDirectory, (err) ->
  if (err)
    console.log(err)
    return
  processingFinished()
)

