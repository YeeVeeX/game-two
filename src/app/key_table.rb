require "gosu"

module App
  # Key NAME -> Gosu constant. This is the ENGINE fact, not a tunable:
  # the names are the data contract (data/bindings.json speaks them), this
  # table is what they mean on this platform. It lives in src/app so
  # src/core stays Gosu-free (spec panel fold); Core::BindingMap receives
  # it by injection. Extending the vocabulary is a one-entry addition.
  #
  # NB Gosu/SDL scancodes are POSITIONAL (a0.5 spec F6 note): on a non-US
  # layout the ";" physical position differs — the per-machine
  # data/bindings.local.json override is the remedy, not this table.
  KEY_TABLE = {}.tap do |t|
    ("A".."Z").each { |c| t[c] = Gosu.const_get("KB_#{c}") }
    ("0".."9").each { |d| t[d] = Gosu.const_get("KB_#{d}") }
    t["Up"] = Gosu::KB_UP
    t["Down"] = Gosu::KB_DOWN
    t["Left"] = Gosu::KB_LEFT
    t["Right"] = Gosu::KB_RIGHT
    t["Space"] = Gosu::KB_SPACE
    t["Tab"] = Gosu::KB_TAB
    t["Enter"] = Gosu::KB_RETURN
    t["LShift"] = Gosu::KB_LEFT_SHIFT
    t["RShift"] = Gosu::KB_RIGHT_SHIFT
    t["LCtrl"] = Gosu::KB_LEFT_CONTROL
    t["RCtrl"] = Gosu::KB_RIGHT_CONTROL
    t["LAlt"] = Gosu::KB_LEFT_ALT
    t[";"] = Gosu::KB_SEMICOLON
    t[","] = Gosu::KB_COMMA
    t["."] = Gosu::KB_PERIOD
    t["Escape"] = Gosu::KB_ESCAPE
  end.freeze
end
