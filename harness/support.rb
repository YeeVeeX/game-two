# Shared harness helpers, loadable WITHOUT gosu (pilot_session tests run
# headless). Gosu is touched only inside save_opaque, at call time — by then
# the caller has already rendered a Gosu::Image, so the constant exists.
module Harness
  # Expands a replay script's {hold:, frames:} input spec into a per-frame
  # Hash(frame => [action strings]) for Core::ScriptedInput.
  def self.expand_script(raw)
    frames = Hash.new { |h, k| h[k] = [] }
    raw.fetch(:hold, {}).each do |action, ranges|
      ranges.each do |(from, to)|
        (from..to).each { |f| frames[f] << action.to_s }
      end
    end
    raw.fetch(:frames, {}).each do |frame, actions|
      frames[Integer(frame.to_s)].concat(actions)
    end
    frames
  end

  # v15 `start` script parameter: begin a world scene with banked value so
  # a focused wall script can exercise seals/Varekka without a farm
  # prologue. Harness plumbing only — pack.bank! is the same audited path
  # the bank station uses, and no game code reads this.
  def self.apply_start(world, start)
    return unless start
    amount = start[:banked]
    world.pack.bank!(amount) if amount && amount.positive?
    # v16: inscribed kit list — state setup on the body's own mark path
    # (the bank! precedent: start params set state, never emit economy
    # events). Unknown kit names fail loud (BindingMap law) — a typo'd
    # script must stop at load, not stage the wrong scene.
    Array(start[:inscribed]).each do |kit|
      body = world.pack.members.find { |m| m.kit_name == kit.to_sym }
      raise ArgumentError, "start.inscribed: unknown kit #{kit.inspect}" unless body
      body.inscribe_mark!
    end
    zone = start[:zone]
    world.start_in(zone.to_s) if zone
  end

  # The window's backbuffer is opaque, but Gosu.render keeps blended alpha
  # (a translucent overlay leaves e.g. a=198 in the PNG), so viewers
  # composite the capture against their own background and misrepresent the
  # frame. Flatten alpha so captures match what the player sees.
  def self.save_opaque(image, path)
    blob = image.to_blob.dup
    (3...blob.bytesize).step(4) { |i| blob.setbyte(i, 255) }
    Gosu::Image.from_blob(image.width, image.height, blob).save(path)
  end
end
