before "deploy", "viget:lockout:check"
before "deploy:migrations", "viget:lockout:check"

namespace :viget do
  namespace :lockout do
    desc 'Lock out deployment. Specify reason with REASON=xyz'
    task :add, :roles => :app do
      fn="LOCKOUT.#{stage}"
      File.delete(fn) rescue nil
      lf=File.new(fn,'w')
      lf.puts("#{ENV['USER']}: #{ENV['REASON']}")
      lf.close
      system "svn add #{fn} && svn ci -m 'Lockout added' #{fn}"
    end

    desc 'Remove any existing lockout.'
    task :remove, :roles => :app do
      system "svn remove LOCKOUT.#{stage} && svn ci -m 'Lockout removed' ."
    end

    desc '[internal] Checks for lockouts and aborts if any are found.'
    task :check do
      lockouts = IO.readlines("LOCKOUT.#{stage}") rescue nil
      unless lockouts.nil?
        puts "\n*** LOCKOUT ***\n\n"
        lockouts.each {|l| puts l}
        puts "\n*** LOCKOUT ***\n\n"
        exit
      end
    end
  end
end
