require "bundler/gem_tasks"

task :default => [:build]

task :fetch do
  sh "cp -r ~/.chef/*.rb ~/.chef/*.pem ./conf/"
  sh "cp ~/.ssh/id_rsa ./conf/"
end

task :build do
   sh "docker build . -t shamwow:latest" 
end
