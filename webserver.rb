#/usr/bin/ruby
# A tiny webserver for web part

require 'optparse'
require 'webrick'
require 'redcarpet'

UWS_V = "0.0.1 Alpha"

$home = File.dirname File.expand_path(__FILE__)
$root = File.join $home,"public_html"
$port = 80
$opts = {}


OptionParser.new do |o|
	o.banner = "Unn4m3d Webserver #{UWS_V}"
	o.on("-hHOME","--home=HOME", "Set another home"){|h| $home = h}
	o.on("-rROOT","--root=ROOT", "Set document root"){|r| $root = r}
	o.on("-pPORT","--port=PORT", "Set port"){|p| $port = p.to_i}
	o.on("-v","--verbose", "Run verbosely"){$opts[:v] = true}
	o.on("-h", "--help", "Print this help"){
		puts o
		exit 0
	}
end.parse!

def dbg(msg)
	puts msg if $opts[:v]
end

def md(text)
	renderer = Redcarpet::Render::HTML.new(hard_wrap: true, filter_html: true)
    options = {
        autolink: true,
        no_intra_emphasis: true,
        fenced_code_blocks: true,
        lax_html_blocks: true,
        strikethrough: true,
        superscript: true,
        space_after_headers: true
    }
    Redcarpet::Markdown.new(renderer, options).render(text)
end

puts "[INFO] Unn4m3d Webserver v#{UWS_V} is starting"
dbg "[INFO] DocumentRoot is #{$root}"
dbg "[INFO] Port is #{$port}"
srv = WEBrick::HTTPServer.new :DocumentRoot => $root, :Port => $port



class MFHServlet < WEBrick::HTTPServlet::AbstractServlet
	attr_reader:handlers
	def set_handler(r,h)
		@handlers ||= {}
		@handlers[r] = h
	end
	
	def initialize(s,h)
		super s
		@handlers = h
		dbg "[INFO] Servlet initialized"
	end
	
	def do_GET(req,res)
		begin
			dbg "[INFO] Processing request to #{req.path}\n\tQuery : #{req.query_string}"
			@handlers.each{
				|k,v|
				if req.path =~ k
					v.call(req,res)
					break
				end
			}
		rescue =>e
			dbg "[CRITICAL] #{e}\n#{e.backtrace}"
		end
	end
end


trap 'INT' do
	dbg "[INFO] Shutting down"
	srv.shutdown
end

handlers = {
	/\.x?html?$/i => Proc.new{|req,response|
		response['Content-Type'] = "text/html"
		if File.exists?(File.join($root,req.path))
			response.status = 200
			response.body = File.read File.join($root,req.path)
		else
			response.status = 404
			response.body = "
				<html>
					<body>
						<h1>404 Not Found</h1>
						<p>Unn4m3d WebServer #{UWS_V}</p>
					</body>
				</html>
			"
		end
	},
	/\.rb$/i => Proc.new{|request,response|
		if File.exists?(File.join($root,request.path)) then
			begin
				response['Content-Type'] = "text/html"
				response.status = 200
				eval File.read File.join($root,request.path)
			rescue => e
				dbg "[CRITICAL] #{e}\n#{e.backtrace}"
			end
		else
			response.status = 404
			response.body = "
				<html>
					<body>
						<h1>404 Not Found</h1>
						<p>Unn4m3d WebServer #{UWS_V}</p>
					</body>
				</html>
			"
		end
	},
	/\.(md|markdown)$/i => Proc.new{|request,response|
		if File.exists?(File.join($root,request.path)) then
			response.status = 200
			response.body = md File.read File.join($root,request.path)
			response['Content-Type'] = "text/html"
		else
			response.status = 404
			response.body = "
				<html>
					<body>
						<h1>404 Not Found</h1>
						<p>Unn4m3d WebServer #{UWS_V}</p>
					</body>
				</html>
			"
			response['Content-Type'] = "text/html"
		end
	}
}

srv.mount "/", MFHServlet, handlers 
srv.start
