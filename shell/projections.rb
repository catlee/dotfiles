# frozen_string_literal: true

require "json"

result = {}

components = Dir.glob('**/app')
  .delete_if { |dir | dir.start_with?('app/assets/') }
  .delete_if { |dir | dir.start_with?('gems/') }
  .delete_if { |dir | dir.start_with?('sorbet/') }
  .map { |dir| dir.split("/")[1..-2] }

%w[ts js].each do |x|
  result["*.test.#{x}"] = {
    alternate: %w[ts js].map do |y|
      [
        "{}.#{y}",
        "{dirname|dirname}{basename}.#{y}",
      ]
    end.flatten,
  }
  result["*.#{x}"] = {
    alternate: %w[ts js].map do |y|
      [
        "{}.test.#{y}",
        "{dirname}/__tests__/{basename}.test.#{y}",
      ]
    end.flatten,
  }
end

template = [
  "# frozen_string_literal: true",
  "# typed: true",
  "",
  "class {camelcase|capitalize|colons}",
  "end",
]

components.each do |component|
  component = component.join("/")
  warn component

  result["components/#{component}/app/*.rb"] = {
    "alternate": [
      "components/#{component}/test/{}_test.rb",
      "components/#{component}/test/unit/{}_test.rb",
    ],
    "type": "source",
    "template": template,
  }
  result["components/#{component}/app/models/*.rb"] = {
    "alternate": [
      "components/#{component}/test/{}_test.rb",
      "components/#{component}/test/unit/{}_test.rb",
    ],
    "type": "model",
    "template": template,
  }
  result["components/#{component}/test/unit/*_test.rb"] = {
    "alternate": [
      "components/#{component}/app/models/{}.rb",
      "components/#{component}/app/{}.rb",
    ],
    "type": "test",
    "template": "",
  }
  result["components/#{component}/test/*_test.rb"] = {
    "alternate": "components/#{component}/app/{}.rb",
    "type": "test",
    "template": "",
  }
end

puts result.to_json
