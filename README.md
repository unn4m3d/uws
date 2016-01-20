# UWS
A tiny Ruby webserver using WEBrick

**VERSION** 0.0.1 Alpha<br/>

##What is done and what isn't

 - [x] Ruby scripting
 - [x] Markdown rendering
 - [ ] Something like .htaccess
 - [ ] API documentation
 - [ ] Multithreading

##What isn't planned
 - Other languages support
 - Low level implementation
 
##Quick HowTo

####Launching
Do `webserver.rb --help` to view launch keys

####HTML
Just put .html or .htm file into your document root folder

####Ruby
Put your .rb file into your document root folder. 
Note you have 2 variables (`request` and `response`) and you must send data to client using `response.body = "..."`, like following :
```ruby
response.body = "<html><body>TEST</body></html>"
```

####Markdown
Put your .md or .markdown file into document root folder

##Changelog

####0.0.1 Alpha
- First version
