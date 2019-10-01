require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

$running = true
Signal.trap("TERM") do
  $running = false
end

while($running) do
  # Check for hot wallet to cold wallet transfer
  Transfer.submitted.each do |transfer|
    begin
      transfer.audit_transfer!
    rescue
      puts "Error on withdraw audit: #{$!}"
      puts $!.backtrace.join("\n")
    end
  end

  # Check for commission transfer
  Commission.submitted.each do |commission|
    begin
      commission.audit_transfer!
    rescue
      puts "Error on withdraw audit: #{$!}"
      puts $!.backtrace.join("\n")
    end
  end


  sleep 5
end
