request = require 'request'
fs = require 'fs'

UNICODE_VERSION = '6.3.0'
BASE_URL = "http://www.unicode.org/Public/#{UNICODE_VERSION}/ucd"

class CharRange
  constructor: (@start, @end, @class) ->
  toString: ->
    return "new CharRange(0x#{@start.toString(16)}, 0x#{@end.toString(16)}, '#{@class}')"

# this loads the GraphemeBreakProperty.txt file for Unicode 6.3.0 and parses it to
# combine ranges and generate CoffeeScript
request "#{BASE_URL}/auxiliary/GraphemeBreakProperty.txt", (err, res, data) ->
  re = /^([0-9A-F]+)(?:\.\.([0-9A-F]+))?\s*;\s*([A-Za-z_]+)/gm
  out = []

  # collect entries in the linebreaking table into ranges
  # to keep things smaller.
  while match = re.exec(data)
    start = match[1]
    end = match[2] ? start  
    type = match[3]
    out.push new CharRange(parseInt(start, 16), parseInt(end, 16), type)

  # sort ranges
  out.sort (a, b) ->
    return a.start - b.start

  fs.writeFile __dirname + '/classes.coffee', """
    # ============================================ #
    # Autogenerated from GraphemeBreakProperty.txt #
    # DO NOT EDIT!                                 #
    # ============================================ #
    
    class CharRange
      constructor: (@start, @end, @class) ->
      
    module.exports = [
      #{out.join('\n  ')}
    ]
  """
