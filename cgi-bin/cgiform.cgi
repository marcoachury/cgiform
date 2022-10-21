#!"C:\Euphoria\bin\eui.exe" 

--An example on how to use mycgi.e in order to process web forms

include mycgi.e as cgi
with batch 

printf( 1, "Content-type: text/html\n\n" ) 
printf( 1, "<html><head> </head><body>\n" ) 
object myvars = cgi:form_data() 

puts(1, cgi:tablify(myvars, "border = 1 " ,{"Field Name", "Field value"}, ""))

sequence request_method = environ_string( "REQUEST_METHOD" ) 
puts(1, "<br>Request_method = "& request_method)
puts (1, "<br>Content Type = "& environ_string("CONTENT_TYPE"))
puts( 1, "\n</body></html>\n\n" ) 

