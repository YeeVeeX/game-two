# MUNDO VIVO FASE 3 spike: flow_field.recompute! cost vs city scale (D1 evidence). Run: ruby -Isrc tools/bench_flow_field.rb
require "core/data_store"
require "core/tile_map"
require "game/flow_field"
require "benchmark"
# cidade sintetica: zone_7 (44x28) replicada em 2x/3x/4x com ruas abertas
base = Core::DataStore.new("data")["zones/zone_7"]
def scaled(cfg, k)
  rows = cfg[:tiles]
  big = []
  k.times { |ky| rows.each { |r| big << (r * k) } }
  # abre corredores entre as copias (colunas/linhas de muralha viram chao) pra ser um mapa unico
  big = big.map { |r| r.gsub(/#/, ".") }
  h = big.length; w = big[0].length
  big[0] = "#" * w; big[h - 1] = "#" * w
  big = big.each_with_index.map { |r, i| (i == 0 || i == h - 1) ? r : "#" + r[1..-2] + "#" }
  cfg.merge(tiles: big, transitions: [], stations: [], enemy_spawns: {}, regions: [],
            pack_spawn: [[2, 2], [3, 2], [4, 2]], water_drained_by: nil, decor: [])
end
[1, 2, 3, 4].each do |k|
  cfg = scaled(base, k)
  map = Core::TileMap.new(cfg)
  ff = Game::FlowField.new(map)
  t = Benchmark.realtime { 20.times { ff.recompute!([map.cols / 2, map.rows / 2]) } } / 20 * 1000
  puts format("cidade %dx = %dx%d tiles (%d) -> flow_field.recompute! = %.2f ms", k, map.cols, map.rows, map.cols * map.rows, t)
end
