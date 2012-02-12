# Cloudserver

This is a tool to generate Word Clouds from source code, such as the following:

![Example Cloud of hibernate-core](http://www.notadomain.com/images/hibernate-cloud.png)

This word cloud shows the 100 most recent words of the hibernate-core project.

The idea for Cloudserver is based on a talk by [Kevlin Henney][1]. Word clouds of code can give some insight on the priorities of a project. Hibernate obviously cares a lot about null-Objects, deals with many Strings and has something to do with transactions.

Cloudserver is quick, easy and offline way to generate such clouds. Previous tools, like [wordle](http://www.wordle.net/) work online. If you are not comfortable with uploading all your source to a website, Cloudserver is a viable alternative.  

## Acknowledgment
Cloudserver is based on an idea by [Kevlin Henney][1].
The implementation uses [node.js](http://nodejs.org/) to process the files and [d3-cloud][d3] by [Jason Davies](http://www.jasondavies.com) to generate the clouds. [d3-cloud][d3] is a layout plugin for the data manipulation library [d3](http://mbostock.github.com/d3/)

## Installation
Cloudserver requires node.js to be installed. On OS X, this can be achieved via [brew]. Just run

    brew install node

Cloudserver uses the [async][a] module, which can be installed via

    npm install async

Since cloudserver is written in [CoffeeScript][cs], this has to installed as well. [CoffeeScript][cs] is also available via [brew]:

    brew install coffee-script

## Usage
The cloudserver requires at least two arguments.

* The language configuration to use
* The directories where it should search for sources

Currently, there are only two language configurations available. Java with (`java`) and Java without common keywords (`javaNoKey`).

The above Cloud was generated via

    ./cloudserver.coffee javaNoKey <pathToHibernateSources>

After processing the sources, the cloudserver opens a webserver on port 4242 and the cloud can be accessed on `http://localhost:4242/`

The generated html accepts the requestParameter `limit` to configure the number of words to show. By default cloudserver shows the 100 most common words. `http://localhost:4242?limit=25` would only show the 25 most common words.

The output can be further configured in the file `webroot/cloud.html`. For more information refere to the documentation of [d3-cloud][d3] and [d3](http://mbostock.github.com/d3/).

## Configuration

The language-specific configuration has to be in a file called `languageName.languageConfig.js`. See `java.languageConfig.js` for a documented example of all the possible configurations.

Other global configurations, like the server port can be manipulated at the top of `cloudserver.coffee` directly.

[1]: http://twitter.com/#!/kevlinhenney
[d3]: https://github.com/jasondavies/d3-cloud
[a]: https://github.com/caolan/async
[cs]: http://coffeescript.org/
[brew]: http://mxcl.github.com/homebrew/