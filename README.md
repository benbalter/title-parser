# Title Parser

A Ruby library to parse and normalize titles from arbitrary strings into their constituent parts (level, role, specialty, etc.).

## Example

```ruby
TitleParser.new('Senior Software Engineer, Widgets').to_h
=> {:level=>"Senior", :role=>"Software Engineer", :department=>"Widgets", :speciality=>nil, :raw_title=>"Senior Software Engineer, Widgets", :to_s=>"Senior Software Engineer, Widgets", :title_normalized=>"senior software engineer, widgets", :people_manager?=>false}

TitleParser.new('Senior Vice President, Widgets').to_h
=> {:level=>"Senior", :role=>"Vice President", :department=>"Widgets", :speciality=>nil, :raw_title=>"Senior Vice President, Widgets", :to_s=>"Senior Vice President, Widgets", :title_normalized=>"senior vice president, widgets", :people_manager?=>true}
```

## Status

This was written years ago for another project, which I'm making open source. It works. Most of the time.

## Customization

Customize `titles.yml` with your organizations roles and levels for more accurate parsing.