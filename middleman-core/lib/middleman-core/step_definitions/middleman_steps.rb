Then /^the file "([^\"]*)" has the contents$/ do |path, contents|
  write_file(path, contents)
  step %Q{the file "#{path}" did change}
end

Then /^the file "([^\"]*)" is removed$/ do |path|
  step %Q{I remove the file "#{path}"}
  step %Q{the file "#{path}" did delete}
end

Then /^the file "([^\"]*)" did change$/ do |path|
	watch(@app_rack.watcher, 1)
end

Then /^the file "([^\"]*)" did delete$/ do |path|
	watch(@app_rack.watcher, 1)
end

Then /^the listener should shutdown$/ do
  @app_rack.watcher && @app_rack.watcher.stop
end


def watch(watcher, n)
	return unless watcher && watcher.listener

	adapter = watcher.listener.adapter

  forced_stop = false
  prevent_deadlock = Proc.new { sleep(10); puts "Forcing stop"; adapter.stop; forced_stop = true }

  t = Thread.new(&prevent_deadlock)
  watcher.wait_for_changes(1)

  unless forced_stop
    Thread.kill(t)
    adapter.report_changes
  end
ensure
  unless forced_stop
    Thread.kill(t) if t
    adapter.stop
  end
end
