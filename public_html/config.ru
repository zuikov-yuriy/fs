require 'rack'
require 'erb'
require './autoload'
require './application'
require 'rack/rewrite'
require 'rack-slashenforce'
require 'mysql'
require 'nokogiri'
require 'net/http'
require 'uri'
require 'json'
require './db/environment'
require 'puma'

use Rack::Reloader
use Rack::CommonLogger
use Rack::Builder
use Rack::Rewrite do
  r301 %r{^/(.*)/$}, '/$1'
end

use Rack::Static,
    :urls => ["/images", "/js", "/css", "/jwplayer", "/bootstrap", "/links.html"],
    :root => './static'


run Application.new




