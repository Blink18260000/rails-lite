require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, params = nil)
    @req = req
    @res = res
    if params
      @params = params.merge(req.params)
    end
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    if already_built_response?
      raise "Double Render Error"
    else
      @res.status = 302
      @res["location"] = url
      session.store_session(@res)
      flash.store_flash(@res)
      @already_built_response = true
    end
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    if already_built_response?
      raise "Double Render Error"
    else
      @res["Content-Type"] = content_type
      @res.write(content)
      session.store_session(@res)
      flash.store_flash(@res)
      @already_built_response = true
    end
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    if already_built_response?
      raise "Double Render Error"
    else
      f = File.read("views/" + self.class.to_s.underscore +
          "/" + template_name.to_s + ".html.erb")
      e = ERB.new(f)
      render_content(e.result(binding), "text/html")
    end

  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # method exposing a `Flash` object
  def flash
    @flash ||= Flash.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name.to_s)
  end
end
