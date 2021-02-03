import Ecto.Query, warn: false

alias Bank.{Customers, Financial}
alias Bank.Customers.{Account, User}
alias Bank.Financial.Transaction
alias Bank.Repo
alias BankWeb.Authentication
alias BankWeb.Router.Helpers, as: Routes
