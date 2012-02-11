fs = require('fs')
path = require('path')

directories = process.argv.splice(2)

whitelist = /.*\.java$/
parseStart = /( )class( )/
globalWords = {}
globalWordsArray = []
webRoot = 'webroot'
maxWords = 100

blacklist = ['return']
#blacklist = ['return', 'public', 'final', 'private', 'class', 'if']

openDirectory = (dir) ->
  fs.stat dir, (err, stats) ->
    if (err)
      console.log(err)
      return
    if (stats.isDirectory())
      fs.readdir dir, (err, files) ->
        if (err)
          console.log(err)
          return
        for file in files
          openDirectory(path.join(dir, file))
    if (stats.isFile())
      processFile(dir)

processFile = (file) ->
  if (file.match whitelist)
    console.log('processing ' + file)
    processingCount += 1
    fs.readFile file, 'UTF-8', parseFile

parseFile = (err, data) ->
  if (err)
    console.log(err)
    processingCount -= 1
    return
  lines = data.split('\n')
  greenLight = false
  for line in lines
    if greenLight || line.match parseStart
      greenLight = true
      processLine line
  processingCount -= 1
  processingFinished()

processLine = (line) ->
  cleaned = line.replace /[^0-9a-zA-Z@]/g, ' '
  words = cleaned.split ' '
  for word in words
    if word and blacklist.indexOf(word.trim()) < 0
      globalWords[word] = globalWords[word] || 0
      globalWords[word] += 1

processingCount = 0
for dir in directories
  openDirectory(dir)

processingFinished = () ->
  if processingCount == 0
    for word, count of globalWords
      globalWordsArray.push {text: word, size: count}
    globalWordsArray.sort (a,b) ->
      return -1 if a.size > b.size
      return 1 if a.size < b.size
      return 0
    console.log('Done parsing')
    #console.log globalWordsArray

# start servers
http = require('http')
url = require('url')
wordServer = http.createServer (req, res) ->
  if req.url.match /^\/json/
    res.writeHead(200, {'Content-Type' : 'application/json'} )
    res.end JSON.stringify(globalWordsArray.slice(0,maxWords))
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


wordServer.listen 4242
