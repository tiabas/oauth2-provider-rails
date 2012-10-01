class ClientApplicationsController < ApplicationController

  before_filter :find_client_application, :except => [:new, :create]

  def index
  end

  def new
    @client_application = ClientApplication.new
  end

  def create
    unless params.fetch(:client_application, false)
      return render :nothing => true, :status => :not_found
    end
    client_params = params[:client_application]
    client_type = client_params.delete(:client_type)
    @client_application = ClientApplication.new(client_params)
    @client_application.client_type = client_type
    if @client_application.save
      flash[:notice] = "Registered the information successfully"
      return redirect_to :action => "show", :id => @client_application.id
    else
      flash[:error] = @client_application.errors
      render :action => "new"
    end
  end

  def edit

  end

  def show

  end

  def update
    @client_application.update_attributes(params)
    if @client_application.valid?
      flash[:notice] = "Updated the client information successfully"
      redirect_to :action => "show",:id => @client_application.id
    else
      flash[:error] = @client_application.errors.full_messages.to_sentence
      render :action => "new"
    end
  end

  def destroy
    @client_application.destroy
    flash[:notice]="Destroyed the client application registration"
    redirect_to :action => "index"
  end
  
  private

  def find_client_application
    @client_application = ClientApplication.find_by_id(params[:id])
  end
end
