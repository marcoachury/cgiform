-- MyCGI.e
-- A try to generalize the CGI form processing
-- Marco Achury 2022

-- Some code from
-- LibCGI v1.6
-- Common Gateway Interface routines for Euphoria
-- Buddy Hyllberg <budmeister1@juno.com>

-- Some code from: 
-- https://openeuphoria.org/forum/136915.wc?last_id=137102
-- Greg Haberek

-- On Windows the standar input is "text mode"
-- we may need to set it as "binary mode"
-- 

include std/dll.e 
include std/io.e 
include std/convert.e 
include std/pretty.e
include std/search.e
include std/sequence.e
include std/text.e
include std/net/url.e as url
include std/types.e

-- Init
ifdef WINDOWS then 	
	constant msvcrt = open_dll( "msvcrt.dll" ) 
	constant _setmode = define_c_func( msvcrt, "_setmode", {C_INT,C_INT}, C_INT )	
	global constant O_BINARY = 0x008000 
	
	function set_mode( integer fn, integer mode ) 
		return c_func( _setmode, {fn,mode} ) 
	end function 

end ifdef

-- To stablish complete set of variables?
-- To put a prefix like CGI_CONTENT_TYPE ?
constant CONTENT_TYPE = lower(environ_string("CONTENT_TYPE"))
constant CONTENT_LENGTH = to_number(environ_string("CONTENT_LENGTH"))


--Return environmental string, 
--if not declared, return the optional second parameter
global function environ_string( sequence name, object default="" ) 
    object value = getenv( name ) 
    if equal( value, -1 ) then 
        return default 
    end if 
    if atom( default ) then 
        value = to_number( value ) 
    end if 
    return value 
end function 

global function method()  -- From libcgi.e
  return getenv("REQUEST_METHOD")
end function

-- Work for simple forms.  Not for files and multipart data
function post_data()
  object in
  sequence buf  buf = {}
  while 1 do
    in = gets(0)
    if equal(in, -1) then
      return buf
    else
      if in[length(in)] = '\n' then  -- strip \n
        in = in[1..length(in)-1]
      end if
      buf &= in
    end if
  end while
end function


function multipart_parse()
	sequence boundary = CONTENT_TYPE[31..$]
	--integer boundary_length = length(boundary)
	ifdef WINDOWS then
		set_mode( STDIN, O_BINARY ) 
	end ifdef
	object bytes = get_bytes( STDIN, CONTENT_LENGTH )
	
	return bytes
end function


-- Return a sequence that contains data from html form
-- Not separated variables.
function cgi_data()
	-- Check for method
	
	
	if equal(upper(method()), "GET") then
		return string_format(environ_string("QUERY_STRING"))
	elsif  equal(upper(method()), "POST") then
		-- Check if multipart or not
		if equal( CONTENT_TYPE, "application/x-www-form-urlencoded") then
			-- simple form
			return string_format(post_data())
		elsif equal(CONTENT_TYPE[1..30], "multipart/form-data; boundary=") then
			return multipart_parse()
		else --Error.  abort?
			return "Error, unexpected Content-Type"
		end if
	else  -- Not called as CGI
		-- abort ??
		return "Error, unexpected Method"
	end if

end function


-- urldecode and split with & and =
function string_format(sequence raw)
	raw = url:decode(raw) --url decode.
	raw = split(raw, "&") --and split variables.
	for i=1 to length(raw) do
		raw[i] = split(raw[i], "=")
	end for
	return raw
end function


global function form_data()
	return cgi_data()  
end function

-- Function Tablify
-- Convert a sequence on an html table
global function tablify(sequence data, sequence toptions="", sequence thead="", sequence tfoot="") 
	sequence tabl = "\n<table "& toptions & ">\n"
	
	-- Add <thead>
	if not string(thead) then -- Senquence, for several columns
		if string(thead[1]) then
			tabl = tabl & "<thead>"
			for i=1 to length(thead) do
				tabl = tabl & "<td>" & thead[i] & "</td>"
			end for
			tabl = tabl & "</thead>"
		end if
	end if
	
	if string(data) then
		if string(thead) then
			tabl = tabl & "<thead><td>" & thead & "</td></thead>"
		end if
	
		tabl = tabl & "<tr><td>" & data & "</td></tr></table>"
		return tabl
	end if
	
	for row = 1 to length(data) do
		tabl = tabl & "\n\n<tr>" 
		for cell = 1 to length(data[row]) do
			tabl = tabl & "<td>" & data[row][cell] & "</td>\n"
		end for
		
		tabl = tabl & "</tr>" 
	end for
	
	tabl = tabl & "\n</table>\n\n"
	--puts(1, tabl) --debug
	return tabl
	
end function

