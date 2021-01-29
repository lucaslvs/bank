import Ecto.Query, warn: false

alias Bank.Customers
alias Bank.Customers.{Account, User}
alias Bank.Repo
alias BankWeb.Authentication
alias BankWeb.Router.Helpers, as: Routes