fs = require('fs')
path = require('path')

directories = process.argv.splice(2)

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
      openFile(dir)

openFile = (file) ->
  console.log(file)


for dir in directories
  openDirectory(dir)
