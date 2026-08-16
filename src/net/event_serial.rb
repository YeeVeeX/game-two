module Net
  # The ONE serialization for sim events — extracted from WorldScene#describe
  # (v17 increment 1). The wall's EVENT lines and the netplay digest both
  # flow through here: the cross-machine sim-identity instrument (etapa 0,
  # three banked md5s) and the desync detector must read the SAME bytes, or
  # a "clean" wall could hide serialization drift the digest would flag.
  module EventSerial
    module_function

    # Payloads carry live Creature objects — log stable identifiers.
    # (Symbols hit the :name branch too — `cause=hate`, not `cause=:hate` —
    # that IS the banked etapa-0 byte format; never "fix" it.)
    def describe(event)
      event.payload.map { |k, v| "#{k}=#{v.respond_to?(:name) ? v.name : v.inspect}" }.join(" ")
    end

    def line(type, frame, event)
      "EVENT #{type} frame=#{frame} #{describe(event)}"
    end
  end
end
