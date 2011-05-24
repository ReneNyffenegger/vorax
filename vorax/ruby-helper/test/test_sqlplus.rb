#!/usr/bin/ruby

require File.expand_path(File.join(File.dirname(__FILE__), 'common'))

class TestSqlplus < Test::Unit::TestCase

  def setup
    @sqlplus = Vorax::Sqlplus.new(Vorax::UnixProcess.new, ["host stty -echo"]) if TestSqlplus.is_linux?
    @sqlplus = Vorax::Sqlplus.new(Vorax::WindowsProcess.new) if TestSqlplus.is_windows?
  end

  def test_output
    # test with the default buffer size
    assert_match /abc\r?\n/, @sqlplus.exec('prompt abc')
    # test with the minimal buffer size possible (1)
    assert_match /#{'a' * 30}\r?\n/, @sqlplus.exec('prompt ' + ('a' * 30))
  end

  def test_session_monitor
    # simple monitor
    @sqlplus.session_owner_monitor = :on_login
    @sqlplus.exec("connect #{TEST_USER}/#{TEST_USER_PWD}@#{TEST_DATABASE}")
    File.open("#{@sqlplus.run_dir}/login.sql") { |f| assert_match /connection_changed.[0-9]+$/, f.read }
    assert_match  @sqlplus.connected_to.upcase, "#{TEST_USER}@#{TEST_DATABASE}".upcase
    # test login injection
    @sqlplus.session_owner_monitor = :never
    ENV['SQLPATH'] = "#{@sqlplus.run_dir}/sqlpath"
    Dir.mkdir(ENV['SQLPATH']) unless File::directory?(ENV['SQLPATH'])
    File.open("#{ENV['SQLPATH']}/login.sql", "w") { |f| f.puts "SET SQLPROMPT MUHAA>" }
    @sqlplus.session_owner_monitor = :on_login
    content = ""
    File.open("#{@sqlplus.run_dir}/login.sql") { |f| content = f.read }
    assert_match /\ASET SQLPROMPT MUHAA>/, content
    assert_match /connection_changed.[0-9]+$/, content
    @sqlplus.session_owner_monitor = :never
    assert_match  @sqlplus.connected_to, "@"
    @sqlplus.exec("connect #{TEST_USER}/#{TEST_USER_PWD}@#{TEST_DATABASE}")
    assert_match  @sqlplus.connected_to, "@"
    @sqlplus.session_owner_monitor = :always
    @sqlplus.exec("connect #{TEST_USER}/#{TEST_USER_PWD}@#{TEST_DATABASE}")
    assert_match  @sqlplus.connected_to.upcase, "#{TEST_USER}@#{TEST_DATABASE}".upcase
  end

  def test_busy
    @sqlplus.nonblock_exec('prompt >>> VORAX')
    ex = assert_raise(RuntimeError) { @sqlplus.nonblock_exec('prompt y') }
    assert_match /Sqlplus busy executing another command./, ex.message
    output = ""
    while buf = @sqlplus.read(100) do
      output << buf
    end
    assert_match />>> VORAX\r?\n/, output
  end

  def test_config_for
    assert_match /set linesize [0-9]+set pagesize [0-9]+/, @sqlplus.config_for(['linesize', 'pagesize']).join
  end
  
  def teardown
    @sqlplus.destroy
  end


end
