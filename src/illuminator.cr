require "./illuminator/*"
require "./config"
require "./log"
require "kemal"

module Illuminator
  config = Config.new "./config/illuminator.conf"

  def self.render_file(path : String, filename : String | Nil, highlight)
    highlight = HTML.escape(highlight)
    files = Dir.children(path).sort.reverse
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

  get "/" do |env|
    render_file(config.get("path"), nil, (env.params.query.has_key? "highlight") ? "<#{env.params.query["highlight"]}>" : "<>")
  end
  get "/index.html" do |env|
    render_file(config.get("path"), nil, (env.params.query.has_key? "highlight") ? "<#{env.params.query["highlight"]}>" : "<>")
  end
  get "/:filename" do |env|
    render_file(
      config.get("path"),
      env.params.url["filename"],
      env.params.query.has_key?("highlight") ? "<#{env.params.query["highlight"]}>" : "<>"
    )
  end

  error 404 do
    render "src/views/404.ecr"
  end

  Kemal.config.port = config.get("port").to_i
  Kemal.run
end
