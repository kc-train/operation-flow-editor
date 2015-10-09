require 'yaml'

str = File.read '131003-all.yaml'
data = YAML.load str

actions = data['操作步骤']

actions.each do |action|
  p action
end