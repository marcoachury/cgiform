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



include std/dll.e 
include std/io.e 
include std/convert.e 
include std/pretty.e
include std/search.e
include std/sequence.e
include std/text.e
include std/net/url.e as url
include std/types.e
include std/math.e

-- Init
-- On Windows the standar input is "text mode"
-- we may need to set it as "binary mode"
-- 
ifdef WINDOWS then 	
	constant msvcrt = open_dll( "msvcrt.dll" ) 
	constant _setmode = define_c_func( msvcrt, "_setmode", {C_INT,C_INT}, C_INT )	
	constant O_BINARY = 0x008000 
	
	function set_mode( integer fn, integer mode ) 
		return c_func( _setmode, {fn,mode} ) 
	end function 

end ifdef

-- To stablish complete set of variables?
-- To put a prefix like CGI_CONTENT_TYPE ?
constant CONTENT_TYPE = environ_string("CONTENT_TYPE")
constant CONTENT_LENGTH = to_number(environ_string("CONTENT_LENGTH"))
constant QUERY_STRING = environ_string("QUERY_STRING")
global constant REQUEST_METHOD = upper(environ_string("REQUEST_METHOD"))



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
	sequence BOUNDARY = CONTENT_TYPE[31..$]
	sequence item_limit = {45,45} & BOUNDARY
	--integer boundary_length = length(boundary)
	ifdef WINDOWS then
		set_mode( STDIN, O_BINARY ) 
	end ifdef
	sequence new_data = get_bytes( STDIN, CONTENT_LENGTH )
	puts(1, "Length New_data = " & sprint(length(new_data) & "\n<br>"))
	if string(new_data) then puts (1, "Is a string!!") end if
	new_data = split(new_data, item_limit)
	puts(1, "Length New_data = " & sprint(length(new_data)& "\n<br>"))
	new_data = new_data[2..$-1]
	
	
	for i = 1 to length (new_data) do
		if equal(new_data[i][1..40], "\r\nContent-Disposition: form-data; name=\"") then
			new_data[i]= new_data[i][41..$]
			--new_data[i]= split(new_data[i], {34,13,10,13,10})
			--new_data[i][1]= split_any(new_data[i][1], {"\"; filename=\"", {34,13,10}, {34,13,10,13,10}})
			/*
			if length(new_data[i][1])=2 then 
				puts(1, "#Debug inside an IF"& "\n<br>")
				split(new_data[i][2], "\"; filename=\"")
			end if
			*/
			puts(1, "Length New_data = " & sprint(length(new_data)))
		else
			--Error! No Content-Disposition !
			
		end if
	end for
	
	puts(1, "Length New_data = " & sprint(length(new_data)))
	new_data = pretty_sprint(new_data)
	new_data = match_replace("\n",new_data,"<br>")
	
	/*
	for i=1 to length(new_data) do
		new_data[i] = split(new_data[i], "; ",,1)
	end for
	/
	

	bytes=""
	
	for i=1 to length(new_data) do
		if mod(i,2)=1 then
			bytes = append(bytes, new_data[i])
		end if
	end for
	
	return bytes
	*/
	return new_data
end function


-- Return a sequence that contains data from html form
-- Not separated variables.
function cgi_data()
	-- Check for method
	if equal(REQUEST_METHOD, "GET") then
		return string_format(QUERY_STRING)
	elsif  equal(REQUEST_METHOD, "POST") then
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
		return "Error, Not CGI or unexpected Method"
	end if
end function


-- urldecode and split with & and =
function string_format(sequence raw)
	raw = split(raw, "&") --and split variables.
	for i=1 to length(raw) do
		raw[i] = split(raw[i], "=")
		if length(raw[i]) != 2 then
			-- Error, unexpected '='
			abort(5)
		end if
		raw[i][1] = url:decode(raw[i][1])
		raw[i][2] = url:decode(raw[i][2])
	end for
	return raw
end function


global function form_data()
	return cgi_data()  
end function

/*
function table_row(sequence cells)
		sequence row = "<tr>" 
		for cell = 1 to length(cells) do
			row = row & "<td>" & cells[cell] & "</td>\n"
		end for
		tabl = tabl & "</tr>\n"
end function
*/



-- Function Tablify
-- Convert a sequence on an html table.
-- If sequence is string become a single cell table.
-- Sequence is better to be nested.  Main sequence is the whole table
-- Subsequences are rows and Sub sub sequences are cells on each row
-- {  { {"cell 1-1"}{"cell 1-2"} } {{"cell 2-1"}{"cell 2-2"}}}
-- If cells are string pass to the html code the same.
-- If not string is pretty printed
-- toption are options to put inside <html> tag
-- thead and tfoot are sequence of data to put on header and footer rows
--

global function tablify(sequence data, sequence toptions="", sequence thead="", sequence tfoot="") 
	
	--Table header
	sequence tabl = "\n<table "& toptions & ">\n"
	
	-- Add <thead> 
	if (not string(thead)) and string(thead[1]) then
		tabl = tabl & "<thead>"
		for i=1 to length(thead) do
			tabl = tabl & "<td>" & thead[i] & "</td>"
		end for
		tabl = tabl & "</thead>"
	end if
	
	if string(data) then  -- If data is one single string
		if string(thead) then
			tabl = tabl & "<thead><td>" & thead & "</td></thead>"
		end if

		--If data is one single string (one cell), expected the same from thead and tfoot
		tabl = tabl & "<tr><td>" & data & "</td></tr>\n"
		
		if string(tfoot) then
		tabl = tabl & "<tfoot><td>" & tfoot & "</td></tfoot>\n"
		end if
		tabl = tabl & "</table>\n"		
		return tabl
	end if
	for row = 1 to length(data) do
		tabl = tabl & "<tr>" 
		for cell = 1 to length(data[row]) do
			if string(data[row][cell]) then
				tabl = tabl & "<td>" & data[row][cell] & "\n</td>\n"
			else
				tabl = tabl & "<td>" & pretty_sprint(data[row][cell]) & "\n</td>\n"
			end if
		end for
		tabl = tabl & " \n\n</tr>\n" 
	end for
	-- Add <tfoot>
	if not string(tfoot) then -- Sequence, for several columns
		if string(tfoot[1]) then
			tabl = tabl & "\n<tfoot>\n"
			for i=1 to length(tfoot) do
				if string(tfoot[i]) then
					tabl = tabl & "<td>" & tfoot[i] & "</td>\n"
				else
					tabl = tabl & "<td>" & pretty_sprint(tfoot[i]) & "</td>\n"
				end if
			end for
			tabl = tabl & "</tfoot>\n"
		end if
	end if
	
	tabl = tabl & "</table>\n"

	return tabl	
end function

