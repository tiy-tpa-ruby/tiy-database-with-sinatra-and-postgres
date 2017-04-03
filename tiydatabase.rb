require 'sinatra'
require 'pg'
require 'sinatra/reloader' if development?

get '/' do
  erb :home
end

get '/employees' do
  database = PG.connect(dbname: "tiy-database")

  @employees = database.exec ("select * from employees")

  erb :employees
end

get '/employee_show' do
  database = PG.connect(dbname: "tiy-database")

  id = params["id"]

  employees = database.exec("select * from employees where id =$1", [id])

  @employee = employees.first

  erb :employee_show
end

get '/new' do
  erb :employees_new
end

get '/employees_new' do
  database = PG.connect(dbname: "tiy-database")

  name     = params["name"]
  phone    = params["phone"]
  address  = params["address"]
  position = params["position"]
  salary   = params["salary"]
  github   = params["github"]
  slack    = params["slack"]

  database.exec("insert into employees (name, phone, address, position, salary, github, slack) values($1, $2, $3, $4, $5, $6, $7)", [name, phone, address, position, salary, github, slack])

  redirect('/')
end

get '/searched' do
  database = PG.connect(dbname: "tiy-database")

  search = params["search"]

  @employees = database.exec("select * from employees where name like $1 or github=$2 or slack=$3", ["%#{search}%", search, search])

  erb :searched
end

get '/edit' do
  database = PG.connect(dbname: "tiy-database")

  id = params["id"]

  employees = database.exec("select * from employees where id =$1", [id])

  @employee = employees.first

  erb :edit
end

get '/update' do
  database = PG.connect(dbname: "tiy-database")

  id       = params["id"]
  name     = params["name"]
  phone    = params["phone"]
  address  = params["address"]
  position = params["position"]
  salary   = params["salary"]
  github   = params["github"]
  slack    = params["slack"]

  database.exec("UPDATE employees SET name = $1, phone = $2, address = $3, position = $4, salary = $5, github = $6, slack =$7 WHERE id = $8;", [name, phone, address, position, salary, github, slack, id])

  employees = database.exec("select * from employees where id = $1", [id])

  @employee = employees.first

  erb :employee_show
end

get '/delete' do
  database = PG.connect(dbname: "tiy-database")

  id = params["id"]

  database.exec("DELETE FROM  employees where id = $1", [id])

  redirect('/employees')
end
