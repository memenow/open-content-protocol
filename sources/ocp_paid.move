module 0x0::ocp_paid {
    use sui::coin::{Coin, from_balance, into_balance};
    use sui::balance::Balance;
    use sui::sui::SUI;
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap};
    use std::string::String;
    use sui::transfer::public_transfer;
    use 0x0::ocp_creator::Creator;
    use sui::tx_context::sender;

    /// The `Paid` struct represents a paid membership or subscription.
    /// It contains information about the member, creator, URL, and description.
    public struct Paid has key, store {
        id: UID,
        member: address,
        creator: address,
        url: String,
        description: String,
    }

    /// The `PaidCustomRequest` struct represents a custom request for a paid membership or subscription.
    /// It contains information about the member, creator, description, and payment.
    public struct PaidCustomRequest has key, store {
        id: UID,
        member: address,
        creator: address,
        description: String,
        payment: Balance<SUI>,
    }

    /// Mints a new `Paid` object and transfers it to the sender.
    ///
    /// # Arguments
    ///
    /// * `creator` - A reference to the `Creator` object associated with the paid membership or subscription.
    /// * `url` - The URL associated with the paid membership or subscription.
    /// * `description` - The description of the paid membership or subscription.
    /// * `ctx` - The transaction context.
    public entry fun mint_paid(
        creator: &Creator,
        url: String,
        description: String,
        ctx: &mut TxContext
    ) {
        let addr = sender(ctx);
        let paid = Paid {
            id: object::new(ctx),
            member: addr,
            creator: 0x0::ocp_creator::get_creator_name(creator),
            url,
            description,
        };
        public_transfer(paid, addr);
    }

    /// Requests a custom paid membership or subscription by placing a `PaidCustomRequest` in the kiosk.
    ///
    /// # Arguments
    ///
    /// * `creator` - The address of the creator associated with the custom request.
    /// * `description` - The description of the custom request.
    /// * `payment` - The payment for the custom request in the form of a `Coin<SUI>`.
    /// * `ctx` - The transaction context.
    public entry fun request_custom_paid(
        creator: address,
        description: String,
        payment: Coin<SUI>,
        ctx: &mut TxContext
    ) {
        let (mut kiosk, kiosk_cap) = kiosk::new(ctx);
        let addr = sender(ctx);
        let request = PaidCustomRequest {
            id: object::new(ctx),
            member: addr,
            creator,
            description,
            payment: into_balance(payment),
        };
        kiosk::place(&mut kiosk, &kiosk_cap, request);
        public_transfer(kiosk, addr);
        public_transfer(kiosk_cap, addr);
    }

    /// Fulfills a custom paid membership or subscription request by taking the `PaidCustomRequest` from the kiosk,
    /// creating a new `Paid` object, transferring it to the member, and transferring the payment to the creator.
    ///
    /// # Arguments
    ///
    /// * `kiosk` - A mutable reference to the `Kiosk` object.
    /// * `kiosk_cap` - A reference to the `KioskOwnerCap` object.
    /// * `request_id` - The ID of the `PaidCustomRequest` to fulfill.
    /// * `url` - The URL associated with the fulfilled custom paid membership or subscription.
    /// * `ctx` - The transaction context.
    public entry fun fulfill_custom_request(
        kiosk: &mut Kiosk,
        kiosk_cap: &KioskOwnerCap,
        request_id: ID,
        url: String,
        ctx: &mut TxContext
    ) {
        let request: PaidCustomRequest = kiosk::take(kiosk, kiosk_cap, request_id);
        let PaidCustomRequest { id, member, creator, description, payment } = request;
        object::delete(id);

        let paid = Paid {
            id: object::new(ctx),
            member,
            creator,
            url,
            description,
        };
        public_transfer(paid, member);

        let payment_coin = from_balance(payment, ctx);
        public_transfer(payment_coin, creator);
    }
}