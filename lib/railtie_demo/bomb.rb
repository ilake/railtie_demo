module RailtieDemo
  class Bomb
    def initialize(app)
      @app = app
    end

    def call(env)
      p "use bomb middleware"
      status, headers, body = @app.call(env)
      headers['Bomb'] = 'Bang'
      [status, headers, body]
    end

    # For Rails 4 
    def self.eager_load!
      p 'eager_load!'
    end
  end
end
