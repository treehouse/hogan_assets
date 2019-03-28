require 'hogan_assets/version'
require 'hogan_assets/config'

module HoganAssets
  extend Config

  autoload :Hogan, 'hogan_assets/hogan'
  autoload :Tilt, 'hogan_assets/tilt'

  if defined? Rails
    require 'hogan_assets/engine'
  else
    require 'sprockets'
    Config.load_yml! if Config.yml_exists?
    Config.template_extensions.each do |ext|
      register_extension(ext)
    end
  end

  def self.register_extension(ext, env: Sprockets)
    if env.respond_to?(:register_transformer)
      env.register_mime_type "text/#{ext}", extensions: [".#{ext}"], charset: :css
      env.register_preprocessor "text/#{ext}", Tilt
    end

    if env.respond_to?(:register_engine)
      args = ["text/#{ext}", Tilt]
      args << { mime_type: "text/#{ext}", silence_deprecation: true } if Sprockets::VERSION.start_with?("3")
      env.register_engine(*args)
    end
  end
end
