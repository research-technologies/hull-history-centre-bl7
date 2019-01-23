// Turbolinks are used so we can't rely on $(document).ready... 
$(document).on("ready page:load",  processReferenceNo);

// HHC reference numbers generally have spaces within them. To search with spaces quotes are usually require:-
// i.e. "HC 123/34" - or indeed just searching without spaces would achieve the same aim.  
// This script simply removes spaces from the text box so that quotations are not needed.  
function processReferenceNo() {
   $('#reference_no').on("blur", function(self) {
     this.value = replaceWhitespace(this.value);
   });  
}


function replaceWhitespace(val) {
  return val.toString().replace(/\s+/g, '');
}