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


ifdef WINDOWS then 	
	constant msvcrt = open_dll( "msvcrt.dll" ) 
	constant _setmode = define_c_func( msvcrt, "_setmode", {C_INT,C_INT}, C_INT ) 
	
	global constant O_BINARY = 0x008000 
	
	function set_mode( integer fn, integer mode ) 
		return c_func( _setmode, {fn,mode} ) 
	end function 

end ifdef

/*
if equal( request_method, "POST" ) then 
 
    sequence content_type = environ_string( "CONTENT_TYPE" ) 
    integer content_length = environ_string( "CONTENT_LENGTH") 

	integer donde = match("boundary=", content_type) + 9
	sequence boundary = content_type[donde..$]
	integer boundary_length = length(boundary)
*/

/*  --Set standar input as "binary"
    ifdef WINDOWS then
		set_mode( STDIN, O_BINARY ) 
	end ifdef
*/

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



-- Return a sequence that contains any data from html form
function raw_data()
	-- Check for method
	sequence content_type = lower(environ_string("CONTENT_TYPE"))
	
	if equal(upper(method()), "GET") then
		return url:decode(getenv("QUERY_STRING"))
	elsif  equal(upper(method()), "POST") then
		-- Check if multipart or not
		if equal( content_type, "application/x-www-form-urlencoded") then
			-- simple form
			return post_data()
		elsif equal(content_type[1..20], "multipart/form-data;") then	
		return "Multipart!!!"
		
		else
			return "Error, unexpected Content-Type"
		end if
	else  -- Not called as CGI
		-- abort ??
		return "Error, unexpected Method"
	end if
	-- Check query string
end function


global function form_data()
	return raw_data()
	--That is raw data.  Must to process more...
		--url decode and split variables.
end function

