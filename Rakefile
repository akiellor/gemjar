require 'rake/packagetask'

directory 'out/war/WEB-INF'

task :clean do
  rm_rf 'out'
end

task :war => [:clean, 'out/war/WEB-INF'] do
  cp_r 'lib', 'out/war/WEB-INF/classes'
  cp_r 'deps', 'out/war/WEB-INF/lib'
  cp 'web.xml', 'out/war/WEB-INF/web.xml'
  chdir('out/war') do
    sh 'zip -r ../../out/app.war .'
  end
end

