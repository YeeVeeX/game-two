require "json"

module App
  # J-6 client preferences: machine-local presentation choices only. This
  # file never enters the world save or lockstep digest. Since it is written
  # by the game, malformed values degrade by key with one named line instead
  # of bricking boot; the next successful write self-heals the whole file.
  class Prefs
    LOCALES = %w[en es pt-br].freeze
    SCALE_PRESETS = ["auto", 1, 2, 3].freeze
    DEFAULTS = { locale: nil, window_scale: nil, fullscreen: false,
                 volumes_db: {}, muted: false }.freeze
    AUDIO_DB_FLOOR = -60.0
    AUDIO_DB_CEILING = 0.0

    attr_reader :locale, :window_scale, :fullscreen, :volumes_db, :muted

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
      @volumes_db = valid_volumes_db(values.fetch(:volumes_db, DEFAULTS[:volumes_db]))
      @muted = valid(:muted, values.fetch(:muted, DEFAULTS[:muted]),
                     DEFAULTS[:muted]) { |v| v == true || v == false }
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

    def volume_db=(pair)
      bus_id, db = pair
      next_volumes = @volumes_db.merge(bus_id.to_s => Float(db))
      commit(:@volumes_db, next_volumes.freeze)
    end

    def muted=(value)
      commit(:@muted, value)
    end

    def to_h
      values = { locale: @locale, window_scale: @window_scale,
                 fullscreen: @fullscreen }.compact
      values[:volumes_db] = @volumes_db unless @volumes_db.empty?
      values[:muted] = true if @muted
      values
    end

    private

    def valid(key, value, fallback)
      return value if value.nil? && fallback.nil?
      return value if yield(value)
      @out.puts "prefs: invalid #{key}=#{value.inspect}; using default #{fallback.inspect}"
      fallback
    end

    def valid_volumes_db(value)
      unless value.is_a?(Hash)
        @out.puts "prefs: invalid volumes_db=#{value.inspect}; using default {}"
        return {}.freeze
      end
      value.each_with_object({}) do |(bus, db), valid|
        key = bus.to_s
        number = Float(db, exception: false)
        if !key.empty? && number && number.between?(AUDIO_DB_FLOOR, AUDIO_DB_CEILING)
          valid[key] = number
        else
          @out.puts "prefs: invalid volumes_db.#{key}=#{db.inspect}; ignoring"
        end
      end.freeze
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
