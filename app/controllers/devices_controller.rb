class DevicesController < ApplicationController

  def index
    @site = Site.includes(:devices).find(params[:site_id])
    @devices = @site.devices
  end

  def all
    @devices = Device.all.includes(:site)
    redirect_to root_path unless Site.any?
  end

  def show
    @site = Site.find(params[:site_id])
    @device = @site.devices.find(params[:id])
    @device_supplies = @device.supplies.includes(:site)
  end

  def new
    @site =  Site.find(params[:site_id])
    @device = @site.devices.build
  end

  def edit
    @site =  Site.find(params[:site_id])
    @device = @site.devices.find(params[:id])
  end

  def create
    @site =  Site.find(params[:site_id])
    @device = @site.devices.build(device_params)
    if @device.save
      flash[:success] = "Device added"
      redirect_to site_device_path(@site, @device)
    else
      render 'new'
    end
  end

  def update
    @site = Site.find(params[:site_id])
    @device = @site.devices.find(params[:id])
    if @device.update_attributes(device_params)
      flash[:success] = "#{@device.name} saved"
      # Needed for changing Site in form, for site_id to be updated for the redirect
      @device.reload
      redirect_to site_device_path(@device.site, @device)
    else
      render 'edit'
    end
  end

  def destroy
    Device.find(params[:id]).destroy
    flash[:warning] = "Device deleted"
    redirect_to site_devices_path
  end

  def assign
    @site = Site.find(params[:site_id])
    @device = @site.devices.find(params[:id])
    @supplies = @site.supplies.order("name")
  end

  def export
    if params[:repair]
      @devices = Device.includes(:site).in_repair
    elsif params[:all]
      @devices = Device.includes(:site).all
    else
      @site = Site.find(params[:site_id])
      @devices = @site.devices
    end

    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"Devices.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  private

  def device_params
    params.require(:device).permit(:name, :devtype, :model, :state, :ip,
                                   :location, :sn, :notes, :site_id,
                                   supply_ids: [])
  end

end
