exports.whitelist = /.*\.java$/
exports.parseStart = /( )class|interface|enum( )/
exports.blacklist = ['return', 'public', 'final', 'private', 'protected', 'class', 'extends', 
  'if', 'else', 'void', 'new', 'for', 'while']
exports.additionalChars = '@'
