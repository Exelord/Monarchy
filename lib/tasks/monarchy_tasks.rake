# frozen_string_literal: true
# desc "Explaining what the task does"
task 'monarchy:reparentize' do
  Monarchy.resource_classes.with_progress.each do |klass|
    klass.all.each do |model|
      model.send(:assign_parent, true)
    end
  end
end

task 'monarchy:hierarchization' do
  Monarchy.resource_classes.with_progress.each do |klass|
    klass.all.each do |model|
      model.send(:ensure_hierarchy)
    end
  end
end
