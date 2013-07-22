class NewfeaturesController < ApplicationController
  before_filter :require_admin, :except => :cancel

  # GET /newfeatures
  # GET /newfeatures.json
  def index
    @newfeature = Newfeature.all(:order => "created_at DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @newfeatures }
    end
  end
  
  # The global notification disappear when clicking cross symbol 
  def cancel
    ClickTime.update_time(User.current.id)

    respond_to do |format|
      format.html 
      format.js
      format.json { render json: @newfeatures }
    end
  end

  # GET /newfeatures/1
  # GET /newfeatures/1.json
  def show
    @newfeature = Newfeature.find(params[:id])

    respond_to do |format|
      format.html # show_admin.html.erb
    end
end

  # GET /newfeatures/new
  # GET /newfeatures/new.json
  def new
    @newfeature = Newfeature.new

    respond_to do |format|
      format.html  # index.html.erb
      format.json { render json: @newfeature }
    end
  end

  # GET /newfeatures/1/edit
  def edit
    @newfeature = Newfeature.find(params[:id])
  end

  # POST /newfeatures
  # POST /newfeatures.json
  def create
    @newfeature = Newfeature.new(params[:newfeature])

    respond_to do |format|
      if @newfeature.save
        format.html { redirect_to newfeatures_url, notice: 'Newfeature was successfully created.' }
        format.json { render json: @newfeature, status: :created, location: @newfeature }
      else
        format.html { render action: "new" }
        format.json { render json: @newfeature.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /newfeatures/1
  # PUT /newfeatures/1.json
  def update
    @newfeature = Newfeature.find(params[:id])

    respond_to do |format|
      if @newfeature.update_attributes(params[:newfeature])
        format.html { redirect_to @newfeature, notice: 'Newfeature was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @newfeature.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /newfeatures/1
  # DELETE /newfeatures/1.json
  def destroy
    @newfeature = Newfeature.find(params[:id])
    @newfeature.destroy

    respond_to do |format|
      format.html { redirect_to newfeatures_url }
      format.json { head :no_content }
    end
  end
end
