module Admin
  class Ability
    include CanCan::Ability

    def initialize(user)
      return unless user.admin?

      can :read, Order
      can :read, Trade
      can :read, Proof
      can :update, Proof
      can :read, Activity
      can :manage, Member
      can :manage, IdDocument
      can :manage, Wallet
      can :manage, Referral

      can :menu, Deposit
      can :manage, ::Deposits::Fiat
      Deposit.descendants.each { |d| can :manage, d }

      can :menu, Withdraw
      Withdraw.descendants.each { |w| can :manage, w }
    end
  end
end
