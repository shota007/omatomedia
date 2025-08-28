class SearchesController < ApplicationController

def search
    # @range = params[:range]
    # @contents = Content.looks(params[:search], params[:word])
    @contents = Content.looks(params[:word])
    render "contents/index"
end

end