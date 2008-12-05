require 'simple_config'

module Marley

  module Configuration
    
    SimpleConfig.for(:marley) do
      load File.join(MARLEY_ROOT, "config", "config.yml"), :if_exists? => true  
    end
    
    def marley_config
      SimpleConfig.for(:marley)
    end
    
    def comments_database_path
      File.join(marley_config.data_directory, 'comments.db')
    end
    
    THEMES_DIRECTORY = File.join(MARLEY_ROOT, 'themes') unless defined?(THEMES_DIRECTORY)
    
    DEFAULT_THEME = "default" unless defined?(DEFAULT_THEME)

    def self.directory_for_theme(theme_name)
      File.join(THEMES_DIRECTORY, theme_name)
    end
    
    def self.base_path
      CONFIG["base_path"] || ""
    end

  end

end