module App
  # Lag P0 T4 (2026-08-20; contract drafts/_lag-t3-verdict-20260820.md §4):
  # env-gated vsync release. Gosu 1.4.6 hard-codes SDL_GL_SetSwapInterval(1)
  # in Gosu::Window's constructor (gem src/Window.cpp:111), AFTER the GL
  # context exists — so no SDL hint can beat it; the release must be a
  # POST-construction call into the SAME loaded SDL2. We resolve that module
  # by HANDLE (GetModuleHandle + GetProcAddress), never by path: the gem
  # ships TWO SDL2.dlls (lib/ = 32-bit vestigial, lib64/ = the live x64 one
  # gosu.rb adds as DLL dir on x64-*), and re-dlopening the wrong one dies
  # error 193 (hit live, first ON run — the FAILED line held, game ran).
  # `was=1` in the boot line IS the same-instance proof: only the live SDL
  # whose GL context is current on this thread reports gosu's interval.
  #
  # Laws: GAME_VSYNC_OFF absent = nil = zero cost (no require, no dlopen —
  # the GAME_FRAME_PROBE precedent; the wall and every gate never set it).
  # One named boot line when attempted; a driver refusal or load failure is
  # NAMED, never fatal (the audio-boot law: the game runs regardless).
  # Presentation-only: swap pacing changes; the tick-locked timebase (one
  # update = one sim tick) is untouched — under vsync release the loop
  # paces on Gosu's own update_interval timer instead of the display.
  module VsyncRelease
    module_function

    # -> nil (flag absent) | one boot line (released / REFUSED / FAILED).
    # `lib` is injectable for tests; production lazy-loads the real SDL.
    def apply(env: ENV, lib: nil)
      return nil unless env["GAME_VSYNC_OFF"]
      lib ||= sdl
      was = lib.SDL_GL_GetSwapInterval
      rc = lib.SDL_GL_SetSwapInterval(0)
      now = lib.SDL_GL_GetSwapInterval
      refused = now.zero? ? "" : " REFUSED"
      "VSYNC off#{refused} (swap_interval=#{now} was=#{was} rc=#{rc})"
    rescue ScriptError, StandardError => e
      # Foreign e.messages embed newlines (ffi's LoadError did, live) —
      # the boot line law is ONE named line.
      "VSYNC off FAILED (#{e.class}: #{e.message.gsub(/\s*\n\s*/, ' ')})"
    end

    # The SDL2 module gosu.so already loaded — by handle, never by path.
    def sdl
      require "ffi"
      k32 = Module.new do
        extend FFI::Library
        ffi_lib "kernel32"
        attach_function :GetModuleHandleA, [:string], :pointer
        attach_function :GetProcAddress, %i[pointer string], :pointer
      end
      handle = k32.GetModuleHandleA("SDL2.dll")
      raise LoadError, "SDL2.dll is not loaded in this process" if handle.null?
      get, set = %w[SDL_GL_GetSwapInterval SDL_GL_SetSwapInterval].map do |name|
        ptr = k32.GetProcAddress(handle, name)
        raise LoadError, "#{name} not found in loaded SDL2.dll" if ptr.null?
        ptr
      end
      LiveSDL.new(get: FFI::Function.new(:int, [], get),
                  set: FFI::Function.new(:int, [:int], set))
    end

    # Thin adapter so apply() (and its tests) speak SDL names.
    class LiveSDL
      def initialize(get:, set:)
        @get = get
        @set = set
      end

      def SDL_GL_GetSwapInterval
        @get.call
      end

      def SDL_GL_SetSwapInterval(interval)
        @set.call(interval)
      end
    end
  end
end
