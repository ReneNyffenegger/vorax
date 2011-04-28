#!/usr/bin/ruby

require 'test/common'

class TestProcess < Test::Unit::TestCase

  SQLPLUS = Vorax::SqlplusUnix if is_linux?
  SQLPLUS = Vorax::SqlplusWindows if is_windows?

  def setup
    Dir.chdir(Dir.tmpdir)
  end

  def test_process_lifecycle
    process = SQLPLUS.new
    pid = process.pid
    assert(pid_exists?(pid), 'an sqlplus process should exist')
    process.destroy
    assert(!pid_exists?(pid), 'the sqlplus process should not be there anymore')
  end

  def pid_exists?(pid)
    Process.getpgid( pid )
    true
  rescue Errno::ESRCH
    false
  end

end
