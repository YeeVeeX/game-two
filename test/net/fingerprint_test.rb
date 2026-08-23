require_relative "../test_helper"
require "net/fingerprint"
require "net/protocol"
require "fileutils"
require "tmpdir"

# v17 increment 5 — handshake identity. Real file trees (tmpdir), the
# local-bindings exclusion, content/rename sensitivity, and the mismatch
# print that NAMES the differing field (W6: the error reaches the person
# who must act).
class FingerprintTest < Minitest::Test
  HELLO = { version: 2, ruby: "3.4.10", platform: "x64-mingw-ucrt",
            fingerprint: "a" * 32, digest_version: 1 }.freeze

  def build_tree(root)
    FileUtils.mkdir_p(File.join(root, "src/game"))
    FileUtils.mkdir_p(File.join(root, "data/balance"))
    File.write(File.join(root, "src/game/world.rb"), "class World; end\n")
    File.write(File.join(root, "data/balance/combat.json"), '{"hp":10}')
    File.write(File.join(root, "Gemfile.lock"), "GEM\n  gosu (1.4.6)\n")
  end

  def test_stable_across_reads_and_sensitive_to_content
    Dir.mktmpdir do |root|
      build_tree(root)
      a = Net::Fingerprint.tree_md5(root)
      assert_equal a, Net::Fingerprint.tree_md5(root), "same tree, same hash"
      File.write(File.join(root, "data/balance/combat.json"), '{"hp":11}')
      refute_equal a, Net::Fingerprint.tree_md5(root), "a data edit must change the hash"
    end
  end

  def test_added_and_renamed_files_change_the_hash
    Dir.mktmpdir do |root|
      build_tree(root)
      a = Net::Fingerprint.tree_md5(root)
      File.write(File.join(root, "src/game/enemy.rb"), "class Enemy; end\n")
      b = Net::Fingerprint.tree_md5(root)
      refute_equal a, b, "a new src file must change the hash"
      FileUtils.mv(File.join(root, "src/game/enemy.rb"), File.join(root, "src/game/foe.rb"))
      refute_equal b, Net::Fingerprint.tree_md5(root), "relpath is part of the entry"
    end
  end

  def test_gemfile_lock_counts_but_non_rb_src_files_do_not
    Dir.mktmpdir do |root|
      build_tree(root)
      a = Net::Fingerprint.tree_md5(root)
      File.write(File.join(root, "src/notes.txt"), "scratch\n")
      assert_equal a, Net::Fingerprint.tree_md5(root), "src is *.rb only"
      File.write(File.join(root, "Gemfile.lock"), "GEM\n  gosu (1.4.7)\n")
      refute_equal a, Net::Fingerprint.tree_md5(root), "a gem drift is a sim drift"
    end
  end

  def test_bindings_local_json_is_excluded
    Dir.mktmpdir do |root|
      build_tree(root)
      a = Net::Fingerprint.tree_md5(root)
      File.write(File.join(root, "data/bindings.local.json"), '{"attack":["J"]}')
      assert_equal a, Net::Fingerprint.tree_md5(root),
                   "per-machine display config must not poison the handshake"
    end
  end

  def test_prefs_local_json_is_excluded
    # s55 review finding: the menu writes data/prefs.local.json per seat
    # (gitignored) — inside the hash, the first pref committed on either
    # seat would refuse every later coop handshake with an unfixable
    # "git pull" hint. Machine-written files never enter shared identity.
    Dir.mktmpdir do |root|
      build_tree(root)
      a = Net::Fingerprint.tree_md5(root)
      File.write(File.join(root, "data/prefs.local.json"), '{"locale":"pt-br"}')
      assert_equal a, Net::Fingerprint.tree_md5(root),
                   "machine-written client prefs must not poison the handshake"
    end
  end

  def test_line_ending_flavor_does_not_change_the_hash
    # Live trap (2026-08-16, first cross-machine join): an autocrlf=true
    # clone re-writes src/data with CRLF on checkout — byte drift, identical
    # sim. The fingerprint hashes EOL-normalized content, so only REAL
    # content drift refuses the handshake.
    Dir.mktmpdir do |root|
      build_tree(root)
      # build_tree used text-mode writes (CRLF on Windows); pin BOTH flavors
      # explicitly — binwrite bypasses the platform's text-mode translation.
      File.binwrite(File.join(root, "src/game/world.rb"), "class World; end\n")
      File.binwrite(File.join(root, "Gemfile.lock"), "GEM\n  gosu (1.4.6)\n")
      a = Net::Fingerprint.tree_md5(root)
      File.binwrite(File.join(root, "src/game/world.rb"), "class World; end\r\n")
      File.binwrite(File.join(root, "Gemfile.lock"), "GEM\r\n  gosu (1.4.6)\r\n")
      assert_equal a, Net::Fingerprint.tree_md5(root),
                   "CRLF checkout of the same commit must fingerprint-match LF"
      File.binwrite(File.join(root, "src/game/world.rb"), "class World; def x; end; end\r\n")
      refute_equal a, Net::Fingerprint.tree_md5(root),
                   "real content drift must still refuse"
    end
  end

  def test_hello_reads_the_real_repo
    h = Net::Fingerprint.hello(root: File.expand_path("../..", __dir__))
    assert_equal Net::Protocol::VERSION, h[:version]
    assert_equal RUBY_VERSION, h[:ruby]
    assert_equal RUBY_PLATFORM, h[:platform]
    assert_equal Net::StateDigest::DIGEST_VERSION, h[:digest_version]
    assert_match(/\A[0-9a-f]{32}\z/, h[:fingerprint])
  end

  def test_mismatch_is_nil_for_identical_seats
    assert_nil Net::Fingerprint.mismatch(HELLO, HELLO.dup)
  end

  def test_mismatch_names_the_differing_field_and_hints_git_pull
    theirs = HELLO.merge(fingerprint: "b" * 32)
    msg = Net::Fingerprint.mismatch(HELLO, theirs)
    assert_match(/sim fingerprint/, msg)
    assert_match(/#{"a" * 32}/, msg)
    assert_match(/#{"b" * 32}/, msg)
    assert_match(/git pull/, msg)
  end

  def test_mismatch_names_every_differing_field
    theirs = HELLO.merge(version: 1, ruby: "3.3.0") # a stale v1 seat
    msg = Net::Fingerprint.mismatch(HELLO, theirs)
    assert_match(/protocol version: ours 2 \/ theirs 1/, msg)
    assert_match(/Ruby version: ours 3\.4\.10 \/ theirs 3\.3\.0/, msg)
    refute_match(/sim fingerprint/, msg, "matching fields stay out of the print")
  end
end
