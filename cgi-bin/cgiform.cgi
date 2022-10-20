#!"C:\Euphoria\bin\eui.exe" 
 
include std/io.e 
include std/convert.e 

include std/pretty.e
include std/search.e
include std/sequence.e
include mycgi.e
include std/datetime.e


with batch 

/* --From libcgi.e

global constant SERVER_VARS = {
  "SERVER_SOFTWARE",   -- the name of the web server.
  "SERVER_VERSION",    -- the version of the web server.
  "SERVER_NAME",       -- the current host name.
  "SERVER_URL",        -- holds the full URL to the server.
  "SERVER_PORT",       -- the port on which the web server is running.
  "SERVER_PROTOCOL",   -- the HTTP version in use (e.g. "HTTP/1.0").
  "GATEWAY_INTERFACE", -- the CGI version in use (e.g. "CGI/1.1").
  "REQUEST_METHOD",    -- the HTTP method used, "GET" or "POST".
  "CONTENT_TYPE",      -- the Content-Type: HTTP field.
  "CONTENT_LENGTH",    -- the Content-Length: HTTP field.
  "REMOTE_USER",       -- the authorized username, if any, else "-";
                       -- this will only be set if the user has accessed a protected URL.
  "REMOTE_HOST",       -- the same as REMOTE_ADDR.
  "REMOTE_ADDR",       -- the IP address of the remote host, "x.x.x.x".
  "SCRIPT_PATH",       -- the path of the script being executed.
  "SCRIPT_NAME",       -- the URI of the script being executed.
  "QUERY_STRING",      -- the query string following the URL.
  "PATH_INFO",         -- any path data following the CGI URL.
  "PATH_TRANSLATED",   -- the full translated path with URL arguments.
  "HTTP_ACCEPT",       -- the MIME types the client will accept.
  "HTTP_USER_AGENT"    -- the client's browser signature.
}

*/



 
printf( STDOUT, "Content-type: text/html\n\n" ) 
printf( STDOUT, "<html><head> </head><body>\n" ) 

object myvars = form_data() 
--pretty_print(1, myvars)

puts(1, tablify(myvars, "border = 1 " ,{"Field Name", "Field value"}, ""))
 
sequence request_method = environ_string( "REQUEST_METHOD" ) 
puts(1, "<br>Request_method = "& request_method)

puts (1, "<br>Content Type = "& environ_string("CONTENT_TYPE"))


puts( 1, "\n</body></html>\n\n" ) 


/*
    printf( STDOUT, "<pre><code>\n" ) 
    printf( STDOUT, "CONTENT_TYPE = \"%s\"\n", {content_type} ) 
    printf( STDOUT, "CONTENT_LENGTH = %d\n", {content_length} ) 
    printf( STDOUT, "REQUEST_METHOD = \"%s\"\n", {request_method} ) 
	*/
	
	/*
	printf( STDOUT, "BOUNDARY = \"%s\"\n", {boundary} ) 
	print (STDOUT, boundary)
	*/
	
	/*
    sequence bytes = get_bytes( STDIN, content_length ) 
	
	object boundaries = match(boundary, bytes)
	puts(1, "Boundaries =")
	print(1, boundaries)
 
    printf( STDOUT, "<p>Received %d bytes!</p>\n", {length(bytes)} ) 
	
	--pretty_print (STDOUT, bytes)
	--puts (STDOUT, bytes)
	*/

	
	/*
	-- Experimento para extraer datos de los bytes 
	sequence tokenized = split(bytes, boundary)
	if equal(tokenized[1], {45,45}) then
		puts(1, "\nPrimer Token correcto\n")
	end if
	*/
	
	
	/*
	for i = 1 to length(tokenized) do
		tokenized[i] = split(tokenized[i], {13,10})
	end for
	*/
	
	/*
	sequence fecha = date()
	fecha[1] = fecha[1]+1900
	sequence marcatiempo = sprintf("%d%d%d%d%d%d", {fecha[1],fecha[2],fecha[3],fecha[4],fecha[5],fecha[6]})
	puts(1, "Marcatiempo = "& marcatiempo)
	integer donde_anexo = match({13,10,13,10},tokenized[3]) + 4
	printf(1, "\nDonde_Anexo = %d\n", {donde_anexo})
	sequence archivo=tokenized[3][donde_anexo..$]
	integer file_output = open("..\\imagenesrecibidas\\img" &marcatiempo &".jpg", "wb")
	puts(file_output, archivo)
	close(file_output)
	puts(1, "\n\n\n Segundo Tokenizado \n\n\n")
	--pretty_print(1,tokenized)
	puts(1, "\nNumero de tokens = ")
	print(1, length(tokenized))
 */
