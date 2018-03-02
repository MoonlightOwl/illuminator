require "./illuminator/*"
require "./config"
require "./log"
require "./renderer"
require "./search"
require "kemal"

module Illuminator
  config = Config.new "./config/illuminator.conf"

  def self.render_query(params : Hash(String, String | Nil), prefix = "")
    query = params.compact.map { |key, value| "#{key}=#{value}" }.join("&")
    query.size > 0 ? prefix + query : ""
  end

  def self.files_list(path : String)
    Dir.children(path).select { |file| file.ends_with? ".log" }.sort.reverse
  end

  def self.render_file(path : String, filename : String | Nil, params)
    renderer = Renderer.new
    highlight = HTML.escape("<#{params.fetch("highlight", "")}>")
    files = files_list(path)
    if filename.is_a? Nil
      if files.empty?
        render "src/views/404.ecr"
      else
        current_file = files.first
        log = Log.new(path + current_file)
        render "src/views/index.ecr"
      end
    else
      if File.exists? path + filename
        current_file = filename
        log = Log.new(path + filename)
        render "src/views/index.ecr"
      else
        render "src/views/404.ecr"
      end
    end
  end

  def self.collect_params(env)
    keys = ["highlight", "colorize", "q", "page"]
    params = {} of String => String | Nil
    env.params.query.each do |name, value|
      if keys.includes? name
        params[name] = value
      end
    end
    params
  end

  get "/" do |env|
    render_file(config.get("path"), nil, collect_params(env))
  end
  get "/index.html" do |env|
    render_file(config.get("path"), nil, collect_params(env))
  end
  get "/:filename" do |env|
    render_file(config.get("path"), env.params.url["filename"], collect_params(env))
  end

  get "/search" do |env|
    if env.params.query.has_key?("q") && !env.params.query["q"].empty?
      renderer = Renderer.new
      files = files_list(config.get("path"))
      params = collect_params(env)
      if params["q"]?.is_a? String
        request = params["q"].as(String)
        if request.size > 2
          page = params["page"]?.is_a?(String) ? params["page"].as(String).to_i : 0
          if page >= 0
            highlight = HTML.escape("<#{params.fetch("highlight", "")}>")
            search = Search.new config.get("path"), files, request.downcase, page
            next render "src/views/search.ecr"
          end
        end
      end
    end
    render "src/views/404.ecr"
  end

  error 404 do
    render "src/views/404.ecr"
  end

  Kemal.config.port = config.get("port").to_i
  Kemal.run
end
