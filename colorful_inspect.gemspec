#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "colorful_inspect"

  s.version = "0.0.3"

  s.summary = "A small library to print objects with colors using pretty_print"
  s.description = s.summary

  s.homepage = "http://github.com/Mon-Ouie/colorful_inspect"

  s.email   = "mon.ouie@gmail.com"
  s.authors = ["Mon ouie"]

  s.files |= Dir["lib/**/*.rb"]
  s.files |= Dir["test/**/*.rb"]
  s.files |= Dir["*.md"]

  s.require_paths = %w[lib]
end
