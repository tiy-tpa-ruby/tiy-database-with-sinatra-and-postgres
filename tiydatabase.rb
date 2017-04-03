require 'sinatra'
require 'pg'
require 'sinatra/reloader' if development?
require 'active_record'

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection(
  adapter: "postgresql",
  database: "tiy-database"
)

class Employee < ActiveRecord::Base
  self.primary_key = "id"
end

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
  @employee = Employee.find(params["id"])
  if @employee
    erb :employee_show
  else
    erb :no_employee_found
  end
end

get '/new' do
  erb :employees_new
end

get '/employees_new' do
  Employee.create(params)

  redirect('/')
end

get '/searched' do
  search = params["search"]

  # Exact match
  # @employees = Employee.where(name: search)

  @employees = Employee.where("name like $1 or github = $2 or slack = $2", "%#{search}%", search)

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

  erb :employee_show
end

get '/delete' do
  database = PG.connect(dbname: "tiy-database")

  @employee = Employee.find(params["id"])

  @employee.destroy

  redirect('/employees')
end
