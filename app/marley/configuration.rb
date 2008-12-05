require 'simple_config'

module Marley

  module Configuration
    
    SimpleConfig.for(:marley) do
      set :base_path, ""
      
      load File.join(MARLEY_ROOT, "config", "config.yml"), :if_exists? => true  
    end
    
    def marley_config
      SimpleConfig.for(:marley)
    end
    
    def comments_database_path
      File.join(marley_config.data_directory, 'comments.db')
    end
    
    def marley_theme_directory
      File.join(MARLEY_ROOT, "themes", marley_config.theme || "default")
    end
    
    def marley_theme_stylesheet_path(stylesheet_name)
      File.join(marley_theme_directory, "stylesheets", "#{stylesheet_name}.css")
    end

  end

end