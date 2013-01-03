#!/usr/bin/env ruby

require 'bundler'
Bundler.require(:default)

require './lib/nntp_indexer'



config = YAML.load(File.open('config.yml'))
NNTPIndexer.new(config).run
sleep

