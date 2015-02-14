# encoding: UTF-8
'config.encoding = "utf-8"'


class Application

  def initialize

  end

  def call(env)
      @env = env
      @req = Rack::Request.new(env)
      response(Rack::Response.new)
  end

  def response(resp)
      resp["Content-Type"] = "text/html; charset=UTF-8"
      resp["Connection"] = "keep-alive"
      resp.set_cookie("Iam", "media server")
      resp.write route
      resp.finish
  end

  def route
    fullpath = @req.fullpath
    r = fullpath.split('/')
    if r[1] == 'play'
      @req.params["play"] = r[2]
      controller(r[1])
    elsif r[1] == 'films' and r[2]
      @req.params["page_active"] = r[2]
      controller(r[1])
    else
        case fullpath
          when "/"
            route_name = "index"
          else
            route_name = fullpath.delete '/'
        end
        route_name = route_name.split('?')
        controller(route_name[0])
    end
  end

  def controller(route_name)
    c = Controller.new(@req)
    if c.respond_to?(route_name)
      c.send route_name
    else
      c.page_not_found
   end
  end


end
