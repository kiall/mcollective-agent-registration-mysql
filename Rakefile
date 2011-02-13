require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/clean'
require 'find'

# Per Project Settings
 
PROJ_NAME = "mcollective-agent-registration-mysql"
PROJ_URL = "https://github.com/kiall/mcollective-agent-registration-mysql"
PROJ_DOC_TITLE = "MCollective Registration MySQL Agent"
PROJ_VERSION = "0.1"
PROJ_RELEASE = "1"

PROJ_FILES = ["src", "README.md", "doc", "ext"]

PKG_MAINT_NAME = "Kiall Mac Innes"
PKG_MAINT_EMAIL = "kiall@managedit.ie"

PKG_DEB_DISTRIBUTION = "phostr"

if ENV['RELEASE_STAGE'] then
    PKG_DEB_DUPLOAD = "apt.phostr.net-" + ENV['RELEASE_STAGE']
else
    PKG_DEB_DUPLOAD = "apt.phostr.net-development"
end

# End Per Project Settings

ENV["BUILD_NUMBER"] ? CURRENT_RELEASE = ENV["BUILD_NUMBER"] : CURRENT_RELEASE = PROJ_RELEASE
ENV["PKG_VERSION"] ? CURRENT_VERSION = ENV["PKG_VERSION"] : CURRENT_VERSION = PROJ_VERSION

CLEAN.include(["build", "doc"])

def announce(msg='')
    STDERR.puts "================"
    STDERR.puts msg
    STDERR.puts "================"
end

def init
    FileUtils.mkdir("build") unless File.exist?("build")
end

def safe_system *args
    raise RuntimeError, "Failed: #{args.join(' ')}" unless system *args
end

desc "Build documentation, tar balls and rpms"
task :default => [:clean, :doc, :package]

# task for building docs
rd = Rake::RDocTask.new(:doc) { |rdoc|
    rdoc.rdoc_dir = 'doc'
    rdoc.template = 'html'
    rdoc.title    = "#{PROJ_DOC_TITLE} version #{CURRENT_VERSION}"
    rdoc.options << '--line-numbers' << '--inline-source' << '--main' << 'MCollective'
}

desc "Run spec tests"
task :test do
#    sh "cd spec;rake"
end

desc "Create a tarball for this release"
task :package => [:clean, :doc] do
    announce "Creating #{PROJ_NAME}-#{CURRENT_VERSION}.tgz"

    FileUtils.mkdir_p("build/#{PROJ_NAME}-#{CURRENT_VERSION}")
    safe_system("cp -R #{PROJ_FILES.join(' ')} build/#{PROJ_NAME}-#{CURRENT_VERSION}")

    announce "Setting Version to #{CURRENT_VERSION}"
    safe_system("cd build/#{PROJ_NAME}-#{CURRENT_VERSION} && find ./ -type f -exec sed -i 's/@DEVELOPMENT_VERSION@/#{CURRENT_VERSION}/' {} \\;")

    safe_system("cd build && tar --exclude .svn -cvzf #{PROJ_NAME}-#{CURRENT_VERSION}.tgz #{PROJ_NAME}-#{CURRENT_VERSION}")
end

namespace :package do
    desc "Create .deb packages"
    task :deb => [:clean, :doc, :package] do
        announce("Building debian packages")

        FileUtils.mkdir_p("build/deb")
        Dir.chdir("build/deb") do
            safe_system %{tar -xzf ../#{PROJ_NAME}-#{CURRENT_VERSION}.tgz}
            safe_system %{cp ../#{PROJ_NAME}-#{CURRENT_VERSION}.tgz #{PROJ_NAME}_#{CURRENT_VERSION}.orig.tar.gz}

            Dir.chdir("#{PROJ_NAME}-#{CURRENT_VERSION}") do
                safe_system %{cp -R ext/debian .}

                File.open("debian/changelog", "w") do |f|
                    f.puts("#{PROJ_NAME} (#{CURRENT_VERSION}-#{CURRENT_RELEASE}) #{PKG_DEB_DISTRIBUTION}; urgency=low")
                    f.puts
                    f.puts("  * Automated release for #{CURRENT_VERSION}-#{CURRENT_RELEASE} by rake package:deb")
                    f.puts
                    f.puts("    See #{PROJ_URL} for full details")
                    f.puts
                    f.puts(" -- #{PKG_MAINT_NAME} <#{PKG_MAINT_EMAIL}>  #{Time.new.strftime('%a, %d %b %Y %H:%M:%S %z')}")
                end

                if ENV['SIGNED'] == '1'
                    if ENV['SIGNWITH']
	                    safe_system %{debuild -i -b -k#{ENV['SIGNWITH']}}
	            else
	                    safe_system %{debuild -i -b}
	            end
                else
                    safe_system %{debuild -i -us -uc -b}
                end
            end

            safe_system %{cp *.deb *.build *.changes ..}
        end
    end
end

namespace :publish do
    desc "Publish .deb packages"
    task :deb do
        announce("Publishing debian packages")

        raise RuntimeError, "dupload target not specified in Rakefile" unless PKG_DEB_DUPLOAD

        Dir.chdir("build/deb") do
            safe_system %{dput #{PKG_DEB_DUPLOAD} #{PROJ_NAME}_#{CURRENT_VERSION}-#{CURRENT_RELEASE}_*.changes}
        end
    end
end
