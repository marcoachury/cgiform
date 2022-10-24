#!"C:\Euphoria\bin\eui.exe" 

-- An example on how to use mycgi.e in order to process web forms


include mycgi.e as cgi
include std/text.e

with batch 

printf( 1, "Content-type: text/html\n\n" ) 
printf( 1, "<html><head> </head><body>\n" ) 

object myvars = cgi:form_data() 


sequence s = sprint(length(myvars))


--       html table        <table> option     -- Cells inside <thead>   -- Cells inside <tfoot>
puts(1, cgi:tablify(myvars, "border = 1 " ,{"Field Name", "Field value", "File Name"}, {"Fields found:", s} ) )

sequence request_method = environ_string( "REQUEST_METHOD" ) --now also defined as global constant

puts(1, "<br>Request_method = "& request_method & "\n<br>")
puts (1, "<br>Content Type = "& environ_string("CONTENT_TYPE") & "\n<br>")
--? myvars
--? s
printf(1, "\n<br>Length of sequence = %d", length(myvars))
puts( 1, "\n</body></html>\n\n" ) 
