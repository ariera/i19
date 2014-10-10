module Fixtures
  def fixture_file(name)
    File.join(I19.gem_path, 'spec', 'fixtures', name)
  end
end
