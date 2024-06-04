module 0x0::ocp_member {
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::clock::{Self, Clock};
    use std::string::String;
    use 0x0::ocp_creator::{Creator, get_creator_name};
  
    /// The `Member` struct represents a member in the OCP.
    /// It contains information about the member, such as the member's address, URL, description, and avatar.
    public struct Member has key, store {
        id: UID,
        name: address,
        url: String,
        description: String,
        avatar: String,
        creator: address,
        expires_at: u64,
    }
  
    /// The `Paid` struct represents a paid membership in the OCP.
    /// It contains information about the paid membership, such as the member's address, creator ID, URL, and description.
    public struct Paid has key, store {
        id: UID,
        member: address,
        creator: address,
        url: String,
        description: String,
    }
  
    /// Mints a new `Member` and transfers it to the sender.
    ///
    /// # Arguments
    ///
    /// * `creator` - The address of the creator.
    /// * `url` - The URL of the member.
    /// * `description` - The description of the member.
    /// * `avatar` - The avatar of the member.
    /// * `clock` - A reference to the `Clock` object.
    /// * `ctx` - The transaction context.
    public entry fun mint_member(
        creator: address,
        url: String,
        description: String,
        avatar: String,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        let now = clock::timestamp_ms(clock);
        let expires_at = now + 30 * 24 * 60 * 60 * 1000; // Membership validity period of one month (in milliseconds)
        let nft = Member {
            id: object::new(ctx),
            name: sender,
            url,
            description,
            avatar,
            creator,
            expires_at,
        };
        transfer::transfer(nft, sender);
    }
  
    /// Renews the membership of a `Member`.
    ///
    /// # Arguments
    ///
    /// * `member` - A mutable reference to the `Member` object.
    /// * `creator` - A reference to the `Creator` object.
    /// * `price_index` - The index of the renewal price in the creator's price list.
    /// * `payment` - The payment in SUI coins.
    /// * `clock` - A reference to the `Clock` object.
    /// * `_ctx` - The transaction context.
    public entry fun renew_member(
        member: &mut Member,
        creator: &Creator,
        price_index: u64,
        payment: Coin<SUI>,
        clock: &Clock,
        _ctx: &mut TxContext
    ) {
        // Get the renewal fee
        let member_prices = 0x0::ocp_creator::get_member_prices(creator);
        let renewal_fee = *vector::borrow(member_prices, price_index);
        assert!(coin::value(&payment) >= renewal_fee, 1);
        let now = clock::timestamp_ms(clock);
        let new_expires_at = if (member.expires_at > now) {
            member.expires_at + 30 * 24 * 60 * 60 * 1000
        } else {
            now + 30 * 24 * 60 * 60 * 1000
        };
        member.expires_at = new_expires_at;
        transfer::public_transfer(payment, member.creator);
    }
  
    /// Checks if a `Member` is active.
    ///
    /// # Arguments
    ///
    /// * `member` - A reference to the `Member` object.
    /// * `clock` - A reference to the `Clock` object.
    ///
    /// # Returns
    ///
    /// * `bool` - `true` if the member is active, `false` otherwise.
    public fun is_member_active(member: &Member, clock: &Clock): bool {
        let now = clock::timestamp_ms(clock);
        member.expires_at > now
    }
  
    /// Gets the expiration time of a `Member`.
    ///
    /// # Arguments
    ///
    /// * `member` - A reference to the `Member` object.
    ///
    /// # Returns
    ///
    /// * `u64` - The expiration timestamp of the member.
    public fun get_member_expiration(member: &Member): u64 {
        member.expires_at
    }
  
    /// Mints a new `Paid` membership and transfers it to the sender.
    ///
    /// # Arguments
    ///
    /// * `creator` - A reference to the `Creator` object associated with the paid membership.
    /// * `url` - The URL of the paid membership.
    /// * `description` - The description of the paid membership.
    /// * `ctx` - The transaction context.
    public entry fun mint_paid(
        creator: &Creator,
        url: String,
        description: String,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        let paid = Paid {
            id: object::new(ctx),
            member: sender,
            creator: get_creator_name(creator),
            url,
            description,
        };
        transfer::transfer(paid, sender);
    }    
}
