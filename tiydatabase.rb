require 'sinatra'
require 'pg'
require 'sinatra/reloader' if development?

require_relative 'active_record_setup'

# This magic tells Sinatra to close the database connection
# after each request
after do
  ActiveRecord::Base.connection.close
end

get '/' do
  erb :home
end

get '/employees' do
  @employees = Employee.all

  erb :employees
end

get '/employee_show' do
  @employee = Employee.find_by(id: params["id"])
  if @employee
    erb :employee_show
  else
    erb :no_employee_found
  end
end

get '/new' do
  # Build a new blank employee so the form is happy
  @employee = Employee.new

  erb :employees_new
end

get '/employees_new' do
  @employee = Employee.create(params)
  if @employee.valid?
    redirect('/')
  else
    erb :employees_new
  end
end

get '/searched' do
  search = params["search"]

  # Exact match
  # @employees = Employee.where(name: search)

  @employees = Employee.where("name like ? or github = ? or slack = ?", "%#{search}%", search, search)

  erb :searched
end

get '/edit' do
  database = PG.connect(dbname: "tiy-database")

  @employee = Employee.find(params["id"])

  erb :edit
end

get '/update' do
  database = PG.connect(dbname: "tiy-database")

  @employee = Employee.find(params["id"])

  # Short hand, since params already has keys that are the names of the columns
  # and the values are the things the user typed into the form
  @employee.update_attributes(params)

  # Long hand
  # @employee.name     = params["name"]
  # @employee.phone    = params["phone"]
  # @employee.address  = params["address"]
  # @employee.position = params["position"]
  # @employee.salary   = params["salary"]
  # @employee.github   = params["github"]
  # @employee.slack    = params["slack"]
  # @employee.save

  if @employee.valid?
    redirect to("/employee_show?id=#{@employee.id}")
  else
    erb :edit
  end
end

get '/delete' do
  database = PG.connect(dbname: "tiy-database")

  @employee = Employee.find(params["id"])

  @employee.destroy

  redirect('/employees')
end
