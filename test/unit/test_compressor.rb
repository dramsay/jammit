require 'test_helper'

class CompressorTest < Test::Unit::TestCase

  def setup
    @compressor = Compressor.new
  end

  def test_javascript_compression
    packed = @compressor.compress_js(Dir['fixtures/src/test*.js'])
    assert packed == File.read('fixtures/jammed/test.js')
  end

  def test_css_compression
    packed = @compressor.compress_css(Dir['fixtures/src/*.css'])
    assert packed == File.read('fixtures/jammed/test.css')
  end

  def test_jst_compilation
    packed = @compressor.compile_jst(Dir['fixtures/src/test*.jst'])
    assert packed == File.read('fixtures/jammed/test.jst')
  end

end
