class PagesController < ApplicationController
    def home
        @photos = Photo.all
    end
end
