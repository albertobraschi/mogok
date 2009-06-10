
package :git, :provides => :scm do
  description 'Git Distributed Version Control'
  version '1.6.1'
  source "http://kernel.org/pub/software/scm/git/git-#{version}.tar.gz"
  requires :git_dependencies
  
  verify do
    has_file '/usr/local/bin/git'
  end
end

package :git_dependencies do
  description 'Git Build Dependencies'
  apt 'git-core', :dependencies_only => true
end
