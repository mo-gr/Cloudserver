exports.whitelist = /.*\.java$/ // a regular expression for the filenames to consider
exports.parseStart = /( )class( )/ // a reg exp for the actual beginning of relevant content of a file
exports.blacklist = ['return'] // an array of blacklistet words
exports.additionalChars = '@' // reg exp fragment of characters to not filter.
