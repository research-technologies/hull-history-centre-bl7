# Book cover coffeescript.  
# This will set the img tag with class of thumbnail-image to a bookcover when the id contains the ISBN (aslong as google has it)
# Example HTML:-
# <img src="" class="thumbnail-image" id="123435665" /> (id being the isbn)
# See https://gist.github.com/cfitz/5265810 for original concept 

insertBookCoverImage = (data) ->
  for isbn, info of data
    imgId = isbn.toLowerCase().replace("isbn:", "")
    thumbnail_url = info.thumbnail_url   
    $("##{imgId}").attr("width", "120")
    $("##{imgId}").attr("src", thumbnail_url)

addBookCovers = (ids) ->
  url = "http://books.google.com/books?bibkeys=#{ids}&jscmd=viewapi&callback=?"
  $.getJSON url, {}, insertBookCoverImage
 
$ -> 
  addBookCovers(( "ISBN:#{bookcover.id}," for bookcover in $('.thumbnail-image[id]')).join(","))
