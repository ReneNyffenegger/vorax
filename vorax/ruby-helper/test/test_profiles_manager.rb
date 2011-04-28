#!/usr/bin/ruby

require 'test/common'

class TestProfilesManager < Test::Unit::TestCase

  def test_repo
    # test create
    repodir = "#{Dir.tmpdir}/vorax_test_#{Time.now.to_f}"
    Dir.mkdir(repodir)
    ProfilesManager.create(repodir, 'muci')
    assert ProfilesManager.initialized?(repodir)
    repo = ProfilesManager.new(repodir)
    repo.master_password = 'muci'
    # test add profile
    repo.add('user@db', 'xxx')
    assert_equal('xxx', repo.password('user@db'))
    repo.add('admin@db')
    assert repo.password('admin@db').nil?
    repo.add('user@db', 'xyz')
    assert_equal('xyz', repo.password('user@db'))
    repo.add('system@orcl', nil, {:important => 'y'})
    assert_equal('y', repo.attribute('system@orcl', 'important'))
    # test exists?
    assert repo.exists?('admin@db')
    assert repo.exists?('user@db')
    # test remove
    repo.remove('admin@db')
    assert !repo.exists?('admin@db')
    repo.remove('invalid stuff')
    # test save
    assert_nothing_raised { repo.save }
  end

end

