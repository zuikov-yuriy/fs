require '/home/ubuntu/RubymineProjects/technica/lib/parser/Fsparsertread.rb'
require 'net/http'
require 'uri'
require 'nokogiri'

describe 'Fsparsertread' do

  let(:fsp) { Fsparsertread.new }

   it 'get_pages_films PAGE = 10' do
     fsp.stub(:get_films_link => [1,2,3])
     fsp.get_pages_films.should eq([[1,2,3]])
   end

   it 'page_search_fs' do
     array_of_page = [[0, 'http://fs.to/video/films/?sort=new'], [1, 'http://fs.to/video/films/?sort=new&page=1']]
     fsp.page_search_fs(0,1).should eq(array_of_page)
   end


  it 'redirected_page' do
     url = 'http://fs.to/view/i109rbr9tpMFWMdNcVRheM'
     fsp.redirected_page(url).should include('?play&file')
  end

  it 'redirected_page NIL' do
    url = 'http://fs.to/view/i109r'
    fsp.redirected_page(url).should eq(nil)
  end

  it 'redirect_file' do
    url = 'http://fs.to/get/dl/8ozpi2omxw9irl75tryn84e5l/The+Evil+Dead.2013.BDRip.1080p.mp4'
    fsp.redirected_file(url).should include('Dead.2013.BDRip.1080p.mp4')
  end

  it 'redirect_file NIL' do
    url = 'http://fs.to/view/i109r'
    fsp.redirected_file(url).should eq(nil)
  end

  it 'page 200' do
    url = 'http://fs.to'
    p = fsp.page(url)
    p.code.should eq("200")
  end

  it 'page 404' do
    url = 'http://fs.to/123'
    p = fsp.page(url)
    p.code.should eq("404")
  end

  it 'page Nil' do
    url = 'dsgdfwrwetewrtewtwertewryewr'
    p = fsp.page(url)
    p.should eq(nil)
  end

  it 'nokogiri nil' do
    url = 'dsgdfwrwetewrtewtwertewryewr'
    n = fsp.nokogiri(url)
    n.should eq(nil)
  end

end