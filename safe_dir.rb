require 'pathname'

# SafePath version of the Dir class providing a SafePath based temporary directory
class SafeDir
  def self.mktmpdir(tmpdir_safe_path_name = 'tmpdir')
    Dir.mktmpdir do |dir|
      relative_path = Pathname.new(dir).relative_path_from(SafePath.new(tmpdir_safe_path_name))
      safe_dir = SafePath.new(tmpdir_safe_path_name).join(relative_path)

      yield safe_dir
    end
  end
end
