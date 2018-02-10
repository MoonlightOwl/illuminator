require "./illuminator/*"
require "./config"
require "./log"
require "./renderer"
require "kemal"

module Illuminator
  config = Config.new "./config/illuminator.conf"
  renderer = Renderer.new

  def self.render_file(path : String, filename : String | Nil, params)
    renderer = Renderer.new
    highlight = HTML.escape("<#{params["highlight"]}>")
    files = Dir.children(path).select { |file| file.ends_with? ".log" }.sort.reverse
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
    params = {"highlight" => "", "colorize" => false}
    params.each_key do |key|
      if env.params.query.has_key? key
        params[key] = env.params.query[key]
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

  error 404 do
    render "src/views/404.ecr"
  end

  Kemal.config.port = config.get("port").to_i
  Kemal.run
end
