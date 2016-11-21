class SupplyMailer < ApplicationMailer
  def ending_notification(supply)
    @supply = supply
    @users = User.notifiable
    mail(to: @users.map(&:email).uniq, subject: "Supply #{@supply.name} is ending")
  end

  def monthly_usage(month, year)
    @month = month
    @year = year
    # Get all the supplies using scope defined in Model
    @supplies = Supply.all_used
    @users = User.notifiable
    mail(to: @users.map(&:email).uniq, subject: "Supplies usage for #{@month} #{@year}")
  end
end