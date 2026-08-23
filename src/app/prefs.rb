require "json"

module App
  # J-6 client preferences: machine-local presentation choices only. This
  # file never enters the world save or lockstep digest. Since it is written
  # by the game, malformed values degrade by key with one named line instead
  # of bricking boot; the next successful write self-heals the whole file.
  class Prefs
    LOCALES = %w[en es pt-br].freeze
    SCALE_PRESETS = ["auto", 1, 2, 3].freeze
    DEFAULTS = { locale: nil, window_scale: nil, fullscreen: false }.freeze

    attr_reader :locale, :window_scale, :fullscreen

    def self.load(path, out: $stdout)
      raw = File.exist?(path) ? JSON.parse(File.read(path), symbolize_names: true) : {}
      new(path:, values: raw, out:)
    rescue JSON::ParserError => e
      out.puts "prefs: invalid JSON (#{e.message.lines.first.strip}); using defaults"
      new(path:, out:)
    rescue SystemCallError => e
      out.puts "prefs: read failed (#{e.message}); using defaults"
      new(path:, out:)
    end

    def initialize(path:, values: {}, out: $stdout)
      @path = path
      @out = out
      @locale = valid(:locale, values[:locale], DEFAULTS[:locale]) { |v| LOCALES.include?(v) }
      @window_scale = valid(:window_scale, values[:window_scale], DEFAULTS[:window_scale]) do |v|
        SCALE_PRESETS.include?(v)
      end
      @fullscreen = valid(:fullscreen, values.fetch(:fullscreen, DEFAULTS[:fullscreen]),
                          DEFAULTS[:fullscreen]) { |v| v == true || v == false }
    end

    def locale=(value)
      commit(:@locale, value)
    end

    def window_scale=(value)
      commit(:@window_scale, value)
    end

    def fullscreen=(value)
      commit(:@fullscreen, value)
    end

    def to_h
      { locale: @locale, window_scale: @window_scale, fullscreen: @fullscreen }.compact
    end

    private

    def valid(key, value, fallback)
      return value if value.nil? && fallback.nil?
      return value if yield(value)
      @out.puts "prefs: invalid #{key}=#{value.inspect}; using default #{fallback.inspect}"
      fallback
    end

    def commit(variable, value)
      instance_variable_set(variable, value)
      File.write(@path, JSON.pretty_generate(to_h) + "\n")
      value
    rescue SystemCallError => e
      @out.puts "prefs: write failed (#{e.message})"
      value
    end
  end
end
