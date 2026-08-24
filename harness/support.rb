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
    # T3 (T5's fixture primitive too): stage pack progression for
    # level-crossing scenes — the same seam SaveState.apply! uses
    # (load_progress! → sync_max_hp!, the P3 order). Harness plumbing
    # only; no game code reads this.
    if (prog = start[:progression])
      world.progression.load_progress!(level: prog.fetch(:level, 1), xp: prog.fetch(:xp, 0))
      world.pack.sync_max_hp!(progression: world.progression)
    end
    # B4 wall scripts: stage dead pack members for mercy/vat scenes — the
    # same take_hit path combat uses (a fresh replay world cannot open with
    # corpses any other way). Harness plumbing only; no game code reads this.
    if (n = start[:dead])
      (world.pack.members - [world.possessed]).first(n).each do |m|
        m.take_hit(damage: m.hp, attacker: world.possessed) until m.dead?
      end
    end
    zone = start[:zone]
    world.start_in(zone.to_s) if zone
    # v16 (d): stage an inscribed vessel for burn-beat scenes — the same
    # body mutation the altar performs (stationless zones cannot inscribe
    # in-run). Applied AFTER the zone move: start_in rebinds bodies, and
    # the mark rides the body either way (swap-inert law).
    world.possessed.inscribe_mark! if start[:inscribed]
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
